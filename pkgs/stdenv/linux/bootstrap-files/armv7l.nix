{
  # Note: do not use Hydra as a source URL. Ask a member of the
  # infrastructure team to mirror the job.
  busybox = import <nix/fetchurl.nix> {
    # from job: https://hydra.nixos.org/job/nixpkgs/cross-trunk/bootstrapTools.armv7l.dist/latest
    # from build: https://hydra.nixos.org/build/114203060
    name = "busybox";
    url = https://tarballs.nixos.org/sha256/7a7a0266d4687eb1b44496d4d185b9ffa9b1c6260c5df1c40a4999c612312bbd;
    # note: the following hash is different than the above hash, due to executable = true
    sha256 = "18qc6w2yykh7nvhjklsqb2zb3fjh4p9r22nvmgj32jr1mjflcsjn";
    executable = true;
  };
  bootstrapTools = import <nix/fetchurl.nix> {
    # from job: https://hydra.nixos.org/job/nixpkgs/cross-trunk/bootstrapTools.armv7l.dist/latest
    # from build: https://hydra.nixos.org/build/114203060
    url = https://tarballs.nixos.org/sha256/cf2968e8085cd3e6b3e9359624060ad24d253800ede48c5338179f6e0082c443;
    sha256 = "cf2968e8085cd3e6b3e9359624060ad24d253800ede48c5338179f6e0082c443";
  };
}
