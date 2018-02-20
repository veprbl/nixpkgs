{ stdenv
, lib
, cacert
, julia
, makeJuliaPath
, deepReq
}:

lib.makeOverridable (
{ pname
, version
, requires ? []
, buildInputs ? []
, propagatedBuildInputs ? []
, checkInputs ? []
, doCheck ? true
, postPatch ? ""
, ... } @ attrs:

let
  _buildInputs = [ julia ] ++ buildInputs ++ lib.optionals doCheck checkInputs;
  LD_LIBRARY_PATH = lib.makeLibraryPath _buildInputs;

  # All ancestral packages in the dependency graph are required
  _allRequires = deepReq requires;
  JULIA_LOAD_PATH = makeJuliaPath _allRequires;

in stdenv.mkDerivation (attrs // {

  name = "julia-${julia.version}-${pname}-${version}";

  buildInputs = _buildInputs ++ _allRequires;
  propagatedBuildInputs = [ julia ] ++ propagatedBuildInputs;

  inherit LD_LIBRARY_PATH JULIA_LOAD_PATH;

  # TODO: To prohibit homebrew is necessary for Darwin but this is fragile
  postPatch = postPatch + lib.optionalString stdenv.isDarwin ''
    # sed -i REQUIRE -e '/@osx\s\+Homebrew/d'
    if [ -f deps/build.jl ]; then
        sed -i deps/build.jl \
            -e '/using\s\+Homebrew/d' \
            -e '/provides(\s*Homebrew\.HB/d' \
            -e '/if\s\+Pkg\.installed(\s*"Homebrew"/,/end/d'
    fi
  '';

  configurePhase = ''
    runHook preConfigure

    export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
    export JULIA_LOAD_PATH="${JULIA_LOAD_PATH}"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}"
    export JULIA_PKGDIR="$out/share/julia/site"

    runHook postConfigure
  '';

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

}))
