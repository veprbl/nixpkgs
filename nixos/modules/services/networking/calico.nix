{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.calico;
in {
  options.services.calico = {
    enable = mkEnableOption "calico";

    package = mkOption {
      description = "Package to use for calico";
      type = types.package;
      default = pkgs.pythonPackages.calico;
    };

    etcd = {
      endpoints = mkOption {
        description = "Etcd endpoints";
        type = types.listOf types.str;
        default = ["http://127.0.0.1:2379"];
      };

      caFile = mkOption {
        description = "Etcd certificate authority file";
        type = types.nullOr types.path;
        default = null;
      };

      certFile = mkOption {
        description = "Etcd cert file";
        type = types.nullOr types.path;
        default = null;
      };

      keyFile = mkOption {
        description = "Etcd key file";
        type = types.nullOr types.path;
        default = null;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.calico-felix = {
      description = "Calico Felix Service";
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [iptables which ipset conntrack_tools iproute nettools];
      environment = {
        FELIX_ETCDENDPOINTS = concatStringsSep "," cfg.etcd.endpoints;
        FELIX_ETCDCAFILE = cfg.etcd.caFile;
        FELIX_ETCDKEYFILE = cfg.etcd.keyFile;
        FELIX_ETCDCERTFILE = cfg.etcd.certFile;
      };
      serviceConfig.ExecStart = "${cfg.package}/bin/calico-felix";
    };

    environment.systemPackages = [cfg.package pkgs.calico-containers];
  };
}
