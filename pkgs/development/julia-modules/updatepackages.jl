#!/usr/bin/env julia -p auto

url = "https://github.com/JuliaLang/METADATA.jl/archive/metadata-v2.zip"
out = "official-packages.json"

# Number of versions to prefetch for each package (newest first)
prefetchlimit = 3

using MetadataTools
import JSON

@eval @everywhere oldpackages = JSON.parse(read($out, String))["packages"]

@everywhere function getversion(packages::Dict{S,Any}, pname::S, rev::S) where {S<:AbstractString}
    package = haskey(packages, pname) ? Nullable(packages[pname]) : Nullable()
    version = if isnull(package)
        Nullable()
    else
        let versions = get(package)["versions"]
            i = findfirst(v -> v["rev"] == rev, versions)
            i > 0 ? Nullable(versions[i]) : Nullable()
        end
    end
    version
end

@everywhere function fixgiturl(url::AbstractString)
    url = replace(url, r"^git://", "https://")
    url = replace(url, r".git$", "")
    url
end

let c = RemoteChannel()
    @async while true
        put!(c, tempname())
    end
    @eval @everywhere function safetempname()
        take!($c)
    end
end

@everywhere function prefetchgit(baseurl::S, sha::S) where {S<:AbstractString}
    url = "$baseurl/archive/$sha.tar.gz"
    tmp = safetempname()
    println("Prefetch $url...")
    sha256 = try
        run(pipeline(`curl -L $url -o $tmp`, stdout = DevNull, stderr = DevNull))
        Nullable(readchomp(pipeline(`nix-hash --type sha256 --base32 --flat $tmp`)))
    catch
        println(STDERR, "Failed to prefetch $url")
        Nullable()
    end
    run(pipeline(`rm -f $tmp`))
    isnull(sha256) ? "" : get(sha256)
end

mktempdir() do tmpd
    archive = joinpath(tmpd, "metadata-v2.zip")

    println("Retrieving metadata...")
    run(pipeline(`curl -L $url -o $archive`))

    println("Extracting archive...")
    run(pipeline(`unzip $archive -d $tmpd`, stdout = DevNull))

    println("Constructing package set...")
    revision = readchomp(pipeline(`unzip -z $archive`, `sed '1d'`))
    metadata = get_all_pkg(meta_path = joinpath(tmpd, "METADATA.jl-metadata-v2"))
    metadata = collect(values(metadata))  # cannot parallelize Dict
    for pkg in metadata
        reverse!(pkg.versions)
    end
    packages = Dict()
    @everywhere desk = RemoteChannel(() -> Channel(16))
    @async while true
        package = take!(desk)
        packages[package[:pname]] = package
    end
    @sync @parallel for pkg in metadata
        url = fixgiturl(pkg.url)
        package = Dict(:pname => pkg.name,
                       :url => url,
                       :versions => map(pkg.versions, 1:length(pkg.versions)) do version, i
                           oldversion = getversion(oldpackages, pkg.name, version.sha)
                           sha256 = if isnull(oldversion)
                               i <= prefetchlimit ? prefetchgit(url, version.sha) : ""
                           else
                               oldsha256 = get(oldversion)["sha256"]
                               if i <= prefetchlimit && oldsha256 == ""
                                   prefetchgit(url, version.sha)
                               else
                                   oldsha256
                               end
                           end
                           Dict(:ver => version.ver,
                                :rev => version.sha,
                                :sha256 => sha256,
                                :requires => version.requires)
                       end)
        put!(desk, package)
    end

    println("Writing package info to $out")
    open(out, "w") do io
        JSON.print(io, Dict(:revision => revision, :packages => packages), 4)
    end
end
