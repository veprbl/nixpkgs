{ config, lib, pkgs, ... }:

with lib;

let

  nssModulesPath = config.system.nssModules.path;
  cfg = config.services.nscd;

in

{

  ###### interface

  options = {

    services.nscd = {

      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable the Name Service Cache Daemon.";
      };

      config = mkOption {
        type = types.lines;
        default = builtins.readFile ./nscd.conf;
        description = "Configuration to use for Name Service Cache Daemon.";
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {
    environment.etc."nscd.conf".text = cfg.config;

    users.users.nscd = {
      isSystemUser = true;
      description = "Name service cache daemon user";
    };

    systemd.services.nscd = {
      description = "Name Service Cache Daemon";

      wantedBy = [ "nss-lookup.target" "nss-user-lookup.target" ];

      environment = { LD_LIBRARY_PATH = nssModulesPath; };

      restartTriggers = [
        config.environment.etc.hosts.source
        config.environment.etc."nsswitch.conf".source
        config.environment.etc."nscd.conf".source
      ];

      serviceConfig = {
        ExecStart = "@${pkgs.unscd}/bin/nscd nscd";
        Type = "forking";
        PIDFile = "/run/nscd/nscd.pid";
        Restart = "always";
        ExecReload = [
          "${pkgs.unscd}/bin/nscd --invalidate passwd"
          "${pkgs.unscd}/bin/nscd --invalidate group"
          "${pkgs.unscd}/bin/nscd --invalidate hosts"
        ];
      };
    };

  };
}
