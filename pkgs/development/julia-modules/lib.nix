{ stdenv
, julia
, pkgs
}:

self:

{

  callPackage = pkgs.newScope self;

  # Determine if package is indeed a Julia package for this specific Julia version.
  isJuliaPackage = pkg:
    builtins.hasAttr "julia" pkg && (builtins.getAttr "julia" pkg) == julia;

  # Construct a Julia package search path.
  makeJuliaPath = packages:
    stdenv.lib.makeSearchPath julia.site (builtins.filter self.isJuliaPackage packages);

  # Generic function for building Julia packages
  buildJuliaPackage = self.callPackage ./lib/build-julia-package.nix { };


}
