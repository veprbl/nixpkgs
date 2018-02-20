# Function that creates a Julia environment with specified packages on JULIA_LOAD_PATH.

{ stdenv
, julia
, buildEnv
, makeWrapper
, isJuliaPackage
, makeJuliaPath
, deepReq
}:

{ packages ? []
}:

let

  name = "${julia.name}-env";

  JULIA_LOAD_PATH = makeJuliaPath (deepReq packages);

# Use pkgs.buildEnv and link /bin of all dependencies?
in stdenv.mkDerivation {
  inherit name;

  phases = [ "installPhase" ];
  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    for prg in ${julia}/bin/*; do
      makeWrapper "$prg" "$out/bin/$(basename $prg)" --set JULIA_LOAD_PATH "${JULIA_LOAD_PATH}"
    done
  '';
}
