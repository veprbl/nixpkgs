{
  # Note: do not use Hydra as a source URL. Ask a member of the
  # infrastructure team to mirror the job.
  busybox = import <nix/fetchurl.nix> {
    # from job: https://hydra.nixos.org/job/nixpkgs/cross-trunk/bootstrapTools.armv5tel.dist/latest
    # from build: https://hydra.nixos.org/build/114203025
    name = "busybox";
    url = https://tarballs.nixos.org/sha256/3091d8e22778d023d51c50526ac4911b617db38b7f092fa3332c1d3ff5bd53b7;
    # note: the following hash is different than the above hash, due to executable = true
    sha256 = "0qxp2fsvs4phbc17g9npj9bsm20ylr8myi5pivcrmxm5qqflgi8d";
    executable = true;
  };
  bootstrapTools = import <nix/fetchurl.nix> {
    # from job: https://hydra.nixos.org/job/nixpkgs/cross-trunk/bootstrapTools.armv5tel.dist/latest
    # from build: https://hydra.nixos.org/build/114203025
    url = https://tarballs.nixos.org/sha256/28327343db5ecc7f7811449ec69280d5867fa5d1d377cab0426beb9d4e059ed6;
    sha256 = "28327343db5ecc7f7811449ec69280d5867fa5d1d377cab0426beb9d4e059ed6";
  };
}
