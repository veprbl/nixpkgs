{ callPackage, lib, ... }:

lib.overrideDerivation (callPackage ./generic-v3.nix {
  version = "3.2.1";
  sha256 = "17drjxry365als0drs56gzdpdjhkhjwg9jwvrhmq5dp9ly0rb2f4";
}) (attrs: { NIX_CFLAGS_COMPILE = "-Wno-error"; })
