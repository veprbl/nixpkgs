{ pkgs, lib, ... }:

with lib;

{
  # Musl
  nixpkgs.localSystem.config = "x86_64-unknown-linux-musl";
  i18n.glibcLocales = pkgs.musl; # blah
}
