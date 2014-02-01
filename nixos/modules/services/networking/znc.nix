{ config, pkgs, ... }:

with pkgs.lib;

let

  cfg = config.services.znc;
  dataDir = "/var/lib/znc";

in

{

  ###### interface

  options = {

    services.znc = {

      enable = mkOption {
        default = false;
        description = ''
          Whether to run ZNC irc bouncer.
        '';
      };

      config = mkOption {
        default = ''
          Version = 1.0
          <Listener l>
              Host = localhost
              Port = 65200
          </Listener>
          LoadModule = webadmin

          <User user>
              Pass = sha256#333d35d7fedf74b2eaa648b8c999c05e569b94dd06516fe559bdb2ac9e454ffa#OCgUv-Q?n0XuXzNVlN!,#
              Admin = true
          </User>
        '';
        type = types.nullOr types.string;
        description = ''
          Initial settings for ZNC with defaults of localhost:65200, user:pass
          and webadmin enabled.

          These settings will be overwritten by znc webadmin on reconfiguration.
          If overwriteConfig option is set config will be overwritten on startup
          with suplied config.
          If you want additional preStart commands set systemd.services.znc.preStart
          and nix will merge it with preStart set by this module.
        '';
      };

      overwriteConfig = mkOption {
        default = false;
        description = ''
          ZNC configuration must be writable. If this option is set, configuration
          will be overwritten on startup. This is usefull if you want to control
          your configuration with nix.
        '';
      };

    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    users.extraUsers = singleton
      { name = "znc";
        uid = config.ids.uids.znc;
        description = "ZNC user";
        home = dataDir;
        createHome = true;
      };

    systemd.services.znc =
      { description = "ZNC irc bouncer";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig.User = "znc";
        serviceConfig.ExecStart = "${pkgs.znc}/bin/znc -f -d ${dataDir}";
        preStart = ''
          mkdir -p ${dataDir}/configs && true

          if ! test -f ${dataDir}/configs/znc.conf || ${if cfg.overwriteConfig then "true" else "false"}; then
            install -Dm644 ${pkgs.writeText "znc.conf" cfg.config} ${dataDir}/configs/znc.conf
          fi
        '';
      };

    environment.systemPackages = [ pkgs.znc ];

  };

}
