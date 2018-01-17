{ callPackage, cudatoolkit8, cudatoolkit9 }:

let
  generic = args: callPackage (import ./generic.nix (removeAttrs args ["cudatoolkit"])) {
    inherit (args) cudatoolkit;
  };

in

{
  nccl2_cudatoolkit8 = generic rec {
    version = "2.1.2-1";
    cudatoolkit = cudatoolkit8;
    srcName = "nccl_${version}+cuda${cudatoolkit.majorVersion}_x86_64.txz";
    sha256 = "1zg64273bx9gkv2xf9qd9fvf22scvpwa8d2lqmj0hiq9h5i9jhv4";
  };

  nccl2_cudatoolkit9 = generic rec {
    version = "2.1.2-1";
    cudatoolkit = cudatoolkit9;
    srcName = "nccl_${version}+cuda${cudatoolkit.majorVersion}_x86_64.txz";
    sha256 = "1khxlibaxfnqxw7xsm9c5v57aayn00370nwd1rb23q00ddc7apq9";
  };
}
