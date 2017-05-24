{ stdenv, callPackage, recurseIntoAttrs, makeRustPlatform, llvm
, targets ? []
, targetToolchains ? []
, targetPatches ? []
}:

let
  rustPlatform = recurseIntoAttrs (makeRustPlatform (callPackage ./bootstrap.nix {}));
in
rec {
  rustc = callPackage ./rustc.nix {
    shortVersion = "1.17.0";
    isRelease = true;
    forceBundledLLVM = false;
    configureFlags = [ "--release-channel=stable" ];
    srcSha = "4baba3895b75f2492df6ce5a28a916307ecd1c088dc1fd02dbfa8a8e86174f87";

    patches = [
      ./patches/darwin-disable-fragile-tcp-tests.patch
    ] ++ stdenv.lib.optional stdenv.needsPax ./patches/grsec.patch;

    inherit llvm;
    inherit targets;
    inherit targetPatches;
    inherit targetToolchains;
    inherit rustPlatform;
  };

  cargo = callPackage ./cargo.nix rec {
    version = "0.18.0";
    srcRev = "fe7b0cdcf5ca7aab81630706ce40b70f6aa2e666";
    srcSha = "164iywv1l3v87b0pznf5kkzxigd6w19myv9d7ka4c65zgrk9n9px";
    depsSha256 = "1mrgd8ib48vxxbhkvsqqq4p19sc6b74x3cd8p6lhhlm6plrajrvm";

    inherit rustc; # the rustc that will be wrapped by cargo
    inherit rustPlatform; # used to build cargo
  };
}
