{ callPackage, Foundation, libobjc, llvm_6 }:

callPackage ./generic.nix (rec {
  inherit Foundation libobjc;
  version = "5.20.1.19";
  sha256 = "0s6l8pqkx5cd9p6l4qld7sqcf7f929xdh0qx45j37z4vzcgbcx05";
  withLLVM = true;
  llvm = llvm_6;
})
