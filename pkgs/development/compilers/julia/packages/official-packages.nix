{ stdenv
, julia
, pkgs
}:

self:
super:

let
  srcs = builtins.fromJSON (builtins.readFile ./packages.json);

  create_packages = name: data:


  packages = lib.mapAttrs create_packages srcs;

in packages




