{callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  version = "1.12.2";
  sha256 = "1akray4l3hgahmb92sbvsqg128c7g7s92jrkf1sp1fjnfjrxq9sf";
})
