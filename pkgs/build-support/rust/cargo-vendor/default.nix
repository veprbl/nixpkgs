{ callPackage, fetchFromGitHub }:

((callPackage ./cargo-vendor.nix {}).cargo_vendor {}).overrideAttrs (attrs: {
  src = fetchFromGitHub {
    owner = "alexcrichton";
    repo = "cargo-vendor";
    #rev = "0.1.23";
    rev = "2501d4868a40fb63c21ef18d7935767d5e6fac50";
    sha256 = "124ydq9bvc9ar8h8lvcz0drrpa79542ihpn3lgrhy9lz9pn8f7rf";
  };
})
