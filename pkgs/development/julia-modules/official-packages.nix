{ lib
}:

self:
super:

let
  metadata = builtins.fromJSON (builtins.readFile ./official-packages.json);

  packages = lib.mapAttrs (_: pkg: self.buildOfficialJuliaPackage pkg) metadata.packages;

in packages
