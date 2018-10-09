{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  inherit stdenv fetchurl perl;
  version = "2.1.1";
in
{
    hello = stdenv.mkDerivation rec {
    name = "hello-${version}";
    buildInputs = [ perl ];
    hardeningDisable = [ "format" ];
    src = fetchurl {
      url = "ftp://ftp.nluug.nl/pub/gnu/hello/${name}.tar.gz";
      sha256 = "c510e3ad0200517e3a14534e494b37dc0770efd733fc35ce2f445dd49c96a7d5";
    };
  };
}
