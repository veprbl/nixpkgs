{ callPackage, ... } @ args:

callPackage ./generic.nix (args // rec {
  version = "${branch}.14";
  branch = "2.8";
  sha256 = "05m1272r5qa2r0ym5vq4figdfnpvcys1fgb1026n5s6xdjd1s1pg";
})
