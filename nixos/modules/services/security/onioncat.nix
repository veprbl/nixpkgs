{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.onioncat;
in {
  options = {
    services.onioncat = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable the Onioncat daemon.
        '';
      };

      hiddenServiceHostname = mkOption {
        type = types.nullOr types.string;
        default = null;
        description = ''
          Hostname of the Tor hidden service to use with onioncat:
          If set, it is expected that the user has configured a Tor hidden service on this address.
          If empty Tor will be automatically configured to set up a new hidden service.
        '';
      };

      hiddenServiceDir = mkOption {
        type = types.string;
        default = "onioncat";
        description = ''
          Sets name of the Tor hidden service directory to use for onioncat.
        '';
      };

      extraOptions = mkOption {
        type = types.separatedString " ";
        default = "";
        description = ''
          The extra command-line options to pass to <command>ocat</command> daemon.
        '';
      };
    };
  };
  config = let
    hostname = if cfg.hiddenServiceHostname == null then
        "$(cat /var/lib/tor/${cfg.hiddenServiceDir}/hostname)"
      else
        cfg.hiddenServiceHostname;
  in mkIf cfg.enable {

    services.tor = mkIf (cfg.hiddenServiceHostname == null) {
      enable = true;
      extraConfig = ''
        HiddenServiceDir /var/lib/tor/${cfg.hiddenServiceDir}/
        HiddenServicePort 8060 127.0.0.1:8060
      '';
    };

    systemd.services.onioncat = {
      description = "Tor Daemon";
      wantedBy = [ "multi-user.target" ];
      after    = [ "tor.service" ];
      path = [ pkgs.nettools ];

      script = ''
        ${pkgs.onioncat}/bin/ocat ${cfg.extraOptions} "${hostname}"
      '';

      serviceConfig = {
        Type = "forking";
        KillSignal = "SIGINT";
        TimeoutSec = 30;
        Restart = "on-failure";
        ProtectHome = "yes";
        ProtectSystem = "yes";
        NoNewPrivileges = "yes";
      };
    };
  };
}
