{ pkgs, lib, ... }:

with lib;

{
  # Musl
  #nixpkgs.localSystem.config = "x86_64-unknown-linux-musl";
  # nixpkgs.localSystem = lib.systems.examples.musl64;
  nixpkgs.localSystem = {
    config = "x86_64-unknown-linux-musl";
    system = "x86_64-linux";
  };
  #i18n.glibcLocales = pkgs.musl; # blah
  i18n.glibcLocales = pkgs.glibcLocales; # blah
  boot.initrd = {
    extraUtilsCommands = ''
      for BIN in ${pkgs.utillinux}/bin/*; do
        copy_bin_and_libs $BIN
      done
    '';
  };

  environment.systemPackages = [ pkgs.lsof pkgs.utillinux ];
}
