# Use busybox for i686-linux since it works on x86_64-linux as well.
(import ./i686.nix) //

{
  bootstrapTools = /nix/store/z54w017jsdyh54qk4g1mkql68lqwp90l-bootstrap-tools.tar.xz;
}
