# Use busybox for i686-linux since it works on x86_64-linux as well.
(import ./i686.nix) //

{
  bootstrapTools = import <nix/fetchurl.nix> {
    url = https://gravity.cs.illinois.edu/build/2177106/download/1/bootstrap-tools.tar.xz;
    sha256 = "848c23d43a7c597b52529901003ef651630cc42af5650ba68368caa076088014";
    # path: /nix/store/fh4d1aq2mrzy84qxyki60b3pwj3m6zm1-stdenv-bootstrap-tools/on-server/bootstrap-tools.tar.xz
  };
}
