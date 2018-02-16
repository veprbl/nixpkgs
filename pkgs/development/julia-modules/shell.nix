with import ../../.. {};

stdenv.mkDerivation {
  name = "update-julia-packages";

  nativeBuildInputs = [
    curl
    unzip
    (juliaLang.buildEnv {
      packages = with juliaPackages; [
        JSON
        MetadataTools
      ];
    })
  ];
}
