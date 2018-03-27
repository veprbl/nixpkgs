import ./make-test.nix ({ pkgs, ...} : {
  name = "environment";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ nequissimus ];
  };

  machine = { config, lib, pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages;
      environment.etc."plainFile".text = ''
        Hello World
      '';
      environment.etc."folder/with/file".text = ''
        Foo Bar!
      '';

      environment.sessionVariables = {
        TERMINFO_DIRS = "/run/current-system/sw/share/terminfo";
        NIXCON = "awesome";
      };

      # Musl
      nixpkgs.localSystem.config = "x86_64-unknown-linux-musl";
      i18n.glibcLocales = pkgs.musl; # blah
      boot.initrd = {
        extraUtilsCommands = ''
          for BIN in ${pkgs.libuuid}/bin/*; do
            copy_bin_and_libs $BIN
          done
        '';
      };
    };

  testScript =
    ''
      $machine->succeed('[ -L "/etc/plainFile" ]');
      $machine->succeed('cat "/etc/plainFile" | grep "Hello World"');
      $machine->succeed('[ -d "/etc/folder" ]');
      $machine->succeed('[ -d "/etc/folder/with" ]');
      $machine->succeed('[ -L "/etc/folder/with/file" ]');
      $machine->succeed('cat "/etc/plainFile" | grep "Hello World"');

      $machine->succeed('echo ''${TERMINFO_DIRS} | grep "/run/current-system/sw/share/terminfo"');
      $machine->succeed('echo ''${NIXCON} | grep "awesome"');
    '';
})
