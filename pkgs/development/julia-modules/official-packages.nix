{ lib
}:

self:
super:

let
  metadata = builtins.fromJSON (builtins.readFile ./official-packages.json);

  packages = lib.mapAttrs (pname: pkg:
  let pkg' = if builtins.hasAttr pname self.pinnedPackages
             then pkg // builtins.getAttr pname self.pinnedPackages
             else pkg;
  in self.buildOfficialJuliaPackage pkg') metadata.packages;

in packages
