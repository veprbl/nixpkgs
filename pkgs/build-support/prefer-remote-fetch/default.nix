# An overlay that download sources on remote builder.
# This is useful when the evaluating machine has a slow
# upload while the builder can fetch faster directly from the source.
# Usage: Put the following snippet in your usual overlay definition:
#
#   self: super:
#     (super.prefer-remote-fetch self super)
# Full configuration example for your own account:
#
# $ mkdir ~/.config/nixpkgs/overlays/
# $ echo 'self: super: super.prefer-remote-fetch self super' > ~/.config/nixpkgs/overlays/prefer-remote-fetch.nix
#
let nolocal = a: if builtins.isAttrs a then (a // { preferLocalBuild = false; }) else a;
in
self: super: builtins.mapAttrs (n: v: x: v (nolocal x)) {
  inherit (super) fetchurl fetchgit fetchhg fetchsvn fetchipfs;
}
