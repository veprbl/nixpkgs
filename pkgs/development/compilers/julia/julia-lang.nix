# Main file

{ stdenv
, julia
, callPackage
}:

rec {

  buildEnv = callPackage ./build-env.nix {
    inherit (pkgs) isJuliaPackage makeJuliaPath;
  };

  withPackages = f:
    let p = f pkgs; in buildEnv { extraLibs = p; };

  pkgs = callPackage ./packages/packages.nix { };
}

