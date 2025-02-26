# To build, use:
# nix-build nixos -I nixos-config=nixos/modules/installer/sd-card/sd-image-raspberrypi.nix -A config.system.build.sdImage
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../profiles/base.nix
    ./sd-image.nix
  ];

  nixpkgs.crossSystem.system = "armv6l-linux";
  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.overlays = [ (final: prev: {
    iproute2 = prev.iproute2.override {
      libbpf = null;
      elfutils = null;
    };
    nix = (prev.nix.override {
      enableDocumentation = false;
      withAWS = false;
    }).overrideAttrs (_: {
      doCheck = false;
      doInstallCheck = false;
    });
  }) ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.supportedFilesystems = {
    cifs = lib.mkForce false;
    bcachefs = lib.mkForce false;
    btrfs = lib.mkForce false;
    nfs = lib.mkForce false;
    zfs = lib.mkForce false;
  };
  boot.initrd.supportedFilesystems.cifs = false;

  boot.consoleLogLevel = lib.mkDefault 7;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi1;
  boot.kernelModules = [ "w1-gpio" "w1-therm" ];

  hardware.deviceTree = {
    enable = true;
    filter = "*rpi-b*.dtb";
    overlays = [
      {
        name = "w1-gpio";
        dtsFile = "${pkgs.linuxKernel.packages.linux_rpi1.kernel.src}/arch/arm/boot/dts/overlays/w1-gpio-overlay.dts";
      }
    ];
  };

  sdImage = {
    populateFirmwareCommands =
      let
        configTxt = pkgs.writeText "config.txt" ''
          # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
          # when attempting to show low-voltage or overtemperature warnings.
          avoid_warnings=1

          [pi0]
          kernel=u-boot-rpi0.bin

          [pi1]
          kernel=u-boot-rpi1.bin
        '';
      in
      ''
        (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)
        cp ${pkgs.ubootRaspberryPi}/u-boot.bin firmware/u-boot-rpi1.bin
        cp ${configTxt} firmware/config.txt
      '';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

  networking.hostName = "ukypi";
  networking.firewall.enable = false; # requires GHC
  time.timeZone = "America/New_York";

  programs.zsh = {
    enable = true;
    interactiveShellInit =
      let
        grml-zshrc_src = pkgs.fetchFromGitHub {
          owner = "grml";
          repo = "grml-etc-core";
          rev = "v0.19.10";
          hash = "sha256-z25+BmX2rctNlc+G5z7SOHUZG6y9zrEX6pnEN57CrZk=";
        };
      in
        "source ${grml-zshrc_src}/etc/zsh/zshrc";
  };
  users.defaultUserShell = pkgs.zsh;
  environment.shells = [ pkgs.zsh ];

  environment.systemPackages = with pkgs; [
    git
    wget
    (python3.withPackages (ps: with ps; [
      bottle
    ]))
    gcc
    (pigpio.overrideAttrs (_: {
      postPatch = ''
        substituteInPlace pigpio.c \
          --replace-fail "rev &= 0xFFFFFF;" "rev = 0x80000e;"
      '';
    }))
    libraspberrypi
  ];
  documentation.enable = false;

  services.openssh.enable = true;

  systemd.shutdownRamfs.enable = false;
  systemd.coredump.enable = false;
  services.journald.extraConfig = "SystemMaxUse=128M";

  services.nscd.enableNsncd = false; # needs rust
  #services.nscd.enable = false;
  #system.nssModules = lib.mkForce [];

  programs.less.lessopen = null;

  systemd.timers."freedns" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5m";
        OnCalendar = "daily";
        Unit = "freedns.service";
      };
  };

  systemd.services."freedns" = {
    script = with pkgs; ''
      set -eu
      USER="$(${coreutils}/bin/cat /home/pi/.freedns/user)"
      PASSWORD="$(${coreutils}/bin/cat /home/pi/.freedns/password)"
      HOST="$(${coreutils}/bin/cat /home/pi/.freedns/host)"
      IP="$(${iproute2}/bin/ip -4 addr show enu1u1 | ${gnugrep}/bin/grep -oP '(?<=inet\s)\d+(\.\d+){3}')"
      ${curl}/bin/curl --silent -v "http://sync.afraid.org/u/?u=$USER&p=$PASSWORD&h=$HOST&ip=$IP"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "pi";
    };
  };

  systemd.services."temp-monitor" = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [ pkgs.curl pkgs.python3 ];
    serviceConfig = {
      Type = "simple";
      User = "pi";
      ExecStart = "/home/pi/temp_monitor.sh";
    };
  };

  fonts.fontconfig.enable = false;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "pi" ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  users.users.pi = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "audio" "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDApEi7lnkacODhmxD9M5zJZb0woe/r01cbvL7XtirL/baRCaznEAcMB0WU9sosc+CS63z4CUGqGKrToKqlBRX2UitACtxjX0jybm8kGCDVx+xQSBtlwps5w+JszuVGPxU6v19vnMlaEK9+NIGKjHR1Q3oGdELLmqtwKBlhXewB1VXdnmDvIUjyxoIY5Ih/nyaVi+AUQdojzSiUg7QlhZVY7iARDzdrD+eXOfADEQgalZHxT6hNFraNwXeyLIL9ZjONzhQWHKDtxrLajBSCsAcmtCMECmmWzDScFI6D4vlWe8y6jo39dwfeHLkIuuFRiOEnAazT4WYAFVO5iAQ5GeSX cardno:20 892 148"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCG7hcQN2UJpGDShLXmJi5183Y+tt23kL/fqHkmFuMTJsLVtnyWY+bdy4aBcuxZ9iRoi6J64ya1Hqg8rjKU8AGsRE06qUNlQWcrsjazIGaqQl9SLRvqsd6RQ/Bi6VZtQ046Sg4+F4oEz2c7HKo9iwBnWtUr391YBda2lyVPSBNIZrVF0VXmd0xMqSKjd5q/ZGV5wz8M9a/LW7fi4v1088OknRqpWW2S1HJcy+5yN6t9DhMaou9tSdyUCeEegA9zWVXCL1PD+f4hYFOfh8vqDSAnB7uKHupwFUNpeZm/4Y6UHmTxWESmQaZfYZQ6bLaoGAoilG9UboVCuug5LbUnTesV2kM0w73DBwmEMML+tZ2QWzq96df+GxC/OPR0szxdkGExk6SQZJjpXIKdm9qcM4epHe/AawbRk0+Ia3ezNG6BXCycVGFEMlk1rTrF7Y1ijvSEhtNNVjqNGd1o8oC2hSzI/x51RXNmdTfQLY4ImX9UKwCPQ145RxU8/jKLPZRFpbc= veprbl@juicer"
    ];
    password = "PbWO4";
  };

  users.motd = "Your catness, welcome!";

  system.stateVersion = "24.05";

}
