{ stdenv, ruby, makeWrapper }:

stdenv.mkDerivation {
  name = "bundler2nix";

  buildInputs = [ makeWrapper ];

  phases = ["installPhase"];
  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${ruby}/bin/ruby $out/bin/bundler2nix \
      --add-flags "${./generate_nix_requirements.rb}"
  '';
}
