{ stdenv, callPackage, lib, openssl, enableNpm ? true }:

let
  buildNodejs = callPackage ./nodejs.nix { inherit openssl; };
in
  buildNodejs {
    inherit enableNpm;
    version = "11.12.0";
    sha256 = "130pwb46galjzn7rwmny45p6a4s7qfaax27rixv980gb2f7pfac4";
  }
