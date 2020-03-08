{
  # Note: do not use Hydra as a source URL. Ask a member of the
  # infrastructure team to mirror the job.
  busybox = import <nix/fetchurl.nix> {
    # from job: https://hydra.nixos.org/job/nixpkgs/cross-trunk/bootstrapTools.armv6l.dist/latest
    # from build: https://hydra.nixos.org/build/114202834
    name = "busybox";
    url = https://tarballs.nixos.org/sha256/d96c7656bf43e9ab24949a0b7f6c7c4a4daf1f89ce10ea6e86aa645cbff65bce;
    # note: the following hash is different than the above hash, due to executable = true
    sha256 = "1q02537cq56wlaxbz3s3kj5vmh6jbm27jhvga6b4m4jycz5sxxp6";
    executable = true;
  };
  bootstrapTools = import <nix/fetchurl.nix> {
    # from job: https://hydra.nixos.org/job/nixpkgs/cross-trunk/bootstrapTools.armv6l.dist/latest
    # from build: https://hydra.nixos.org/build/114202834
    url = https://tarballs.nixos.org/sha256/0810fe74f8cd09831f177d075bd451a66b71278d3cc8db55b07c5e38ef3fbf3f;
    sha256 = "0810fe74f8cd09831f177d075bd451a66b71278d3cc8db55b07c5e38ef3fbf3f";
  };
}
