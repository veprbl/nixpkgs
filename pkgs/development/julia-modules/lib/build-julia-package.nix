{ stdenv
, julia
, makeJuliaPath
}:

{ pname
, version
, buildInputs ? []
, propagatedbuildInputs ? []
, checkInputs ? []
, doCheck ? true
, ... } @ attrs:

let

  JULIA_LOAD_PATH = makeJuliaPath propagatedbuildInputs;

in  stdenv.mkDerivation (attrs // {

  name = "julia-${julia.version}-${pname}-${version}";

  buildInputs = [ julia ] ++ buildInputs ++ stdenv.lib.optionals doCheck checkInputs;
  propagatedbuildInputs = [ julia ] ++ propagatedbuildInputs;

  phases = [ "unpackPhase" "patchPhase" "buildPhase" "installPhase" "fixupPhase" "checkPhase" ];

  inherit JULIA_LOAD_PATH;

  # We only need to build when deps/build.jl exists. Otherwise, we have a pure Julia package
  # that can be used straight away.
  # https://docs.julialang.org/en/release-0.5/stdlib/pkg/#Base.Pkg.build
  buildPhase = ''
    runHook preBuild

    if [ -f "deps/build.jl" ]; then
      julia deps/build.jl
    fi

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/${julia.site}/${pname}"
    cp -R . "$out/${julia.site}/${pname}"

    runHook postInstall
  '';

  # Run tests. We disable tests explicitly when they're not provided.
  # https://docs.julialang.org/en/release-0.5/stdlib/pkg/#Base.Pkg.test
  checkPhase = ''
    runHook preCheck

    julia test/runtests.jl

    runHook postCheck
  '';


  passthru = {
    inherit julia;
  };

})
