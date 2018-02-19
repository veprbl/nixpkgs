{ stdenv
, julia
, pkgs
, overrides ? (self: super: {})
}:

let
  inherit (stdenv.lib) fix' extends;


  lib = pkgs.callPackage ./lib.nix {};

  official-packages = pkgs.callPackage ./official-packages.nix {};

  common-overrides = pkgs.callPackage ./common-overrides.nix {};

in fix' (extends overrides (extends common-overrides (extends official-packages lib)))
