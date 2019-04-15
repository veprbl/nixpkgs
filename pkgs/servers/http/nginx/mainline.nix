{ callPackage, ... }@args:

callPackage ./generic.nix (args // {
  version = "1.15.11";
  sha256 = "1bgqwf4g7hc24jyfw6ar4kv6y3mmvbzj4wmh938aks7bwa2jdsym";
})

