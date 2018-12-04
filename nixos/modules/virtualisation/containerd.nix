# Systemd services for containerd.

{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.virtualisation.containerd;

in

{
  ###### interface

  options.virtualisation.containerd = {
    enable =
      mkOption {
        type = types.bool;
        default = false;
        description =
          ''
            This option enables containerd, a daemon that manages
            linux containers.
          '';
      };

    listenOptions =
      mkOption {
        type = types.listOf types.str;
        default = ["/run/containerd/containerd.sock"];
        description =
          ''
            A list of unix and tcp containerd should listen to. The format follows
            ListenStream as described in systemd.socket(5).
          '';
      };

    extraOptions =
      mkOption {
        type = types.separatedString " ";
        default = "";
        description =
          ''
            The extra command-line options to pass to
            <command>containerd</command> daemon.
          '';
      };
    };

  ###### implementation

  config = mkIf cfg.enable (mkMerge [{
      environment.systemPackages = [ cfg.containerd ];
      systemd.packages = [ cfg.containerd ];

      systemd.services.containerd = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = [
            ""
            ''
              ${cfg.package}/bin/containerd \
                ${cfg.extraOptions}
            ''];
        };
        path = [ pkgs.containerd pkgs.runc ];
      };

      systemd.sockets.containerd = {
        description = "Containerd Socket for the API";
        wantedBy = [ "sockets.target" ];
        socketConfig = {
          ListenStream = cfg.listenOptions;
          SocketMode = "0660";
          SocketUser = "root";
          SocketGroup = "root";
        };
      };
    }
  ]);

}
