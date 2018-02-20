{ stdenv
, lib
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

  # Build official Julia packages
  buildOfficialJuliaPackage = self.callPackage ./lib/build-official-julia-package.nix { };

  # Parse REQUIRE file
  parseRequires = self.callPackage ./lib/parse-requires.nix {
    inherit self;
  };

  # Get all required packages including those of ancestors (of ancestors (of ...)).
  deepReq = requires:
  let
    recur = rs:
    if rs == [] then [] else
    let r = builtins.head rs; rs' = builtins.tail rs; in
    [r] ++ lib.optionals (builtins.hasAttr "requires" r) (recur r.requires) ++ recur rs';
  in lib.unique (recur requires);
}
