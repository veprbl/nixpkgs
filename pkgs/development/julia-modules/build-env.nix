# Function that creates a Julia environment with specified packages on LOAD_JULIA_PATH.

{ stdenv
, julia
, buildEnv
, makeWrapper
, isJuliaPackage
, makeJuliaPath
}:

{ packages ? []
}:

let

  name = "${julia.name}-env";

  # Julia packages
  dependencies = stdenv.lib.filter isJuliaPackage (stdenv.lib.closePropagation packages);

  JULIA_LOAD_PATH = makeJuliaPath dependencies;

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
