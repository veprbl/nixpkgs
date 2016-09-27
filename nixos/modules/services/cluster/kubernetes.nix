{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.kubernetes;

  packageHash = pkg: head (splitString "-" (removePrefix "/nix/store/" pkg));

  skipAttrs = attrs: map (filterAttrs (k: v: k != "enable"))
    (filter (v: !(hasAttr "enable" v) || v.enable) attrs);

  infraContainer = pkgs.dockerTools.buildImage {
    name = "pause";
    tag = packageHash cfg.package.pause;
    contents = cfg.package.pause;
    config.Cmd = "/bin/pause";
  };

  kubernetesContainer = pkgs.dockerTools.buildImage {
    name = "kubernetes";
    tag = packageHash cfg.package;
    contents = cfg.package;
  };

  calicoK8SPolicyContainer = pkgs.dockerTools.buildImage {
    name = "calico-k8s-policy";
    tag = packageHash pkgs.calico-k8s-policy;
    contents = pkgs.calico-k8s-policy;
    config.Cmd = "/bin/calico-k8s-policy";
  };

  kubeconfig = pkgs.writeText "kubeconfig" (builtins.toJSON {
    apiVersion = "v1";
    kind = "Config";
    clusters = [{
      name = "local";
      cluster.certificate-authority = cfg.kubeconfig.caFile;
    }];
    users = [{
      name = "kubelet";
      user = {
        client-certificate = cfg.kubeconfig.certFile;
        client-key = cfg.kubeconfig.keyFile;
      };
    }];
    contexts = [{
      context = {
        cluster = "local";
        user = "kubelet";
      };
      current-context = "kubelet-context";
    }];
  });

  kubeconfigDefined = (
    cfg.kubeconfig.caFile != null &&
    cfg.kubeconfig.certFile != null &&
    cfg.kubeconfig.keyFile != null
  );

in {

  ###### interface

  options.services.kubernetes = {
    roles = mkOption {
      description = ''
        Kubernetes role that this machine should take.

        Master role will enable etcd, apiserver, scheduler and controller manager
        services. Node role will enable etcd, docker, kubelet and proxy services.
      '';
      default = [];
      type = types.listOf (types.enum ["master" "node"]);
    };

    package = mkOption {
      description = "Kubernetes package to use.";
      type = types.package;
      default = pkgs.kubernetes;
    };

    image = mkOption {
      description = ''
        Name of the docker image to use for apiserver (by default uses docker image build by nix)
      '';
      type = types.str;
      default = "kubernetes:${packageHash cfg.package}";
    };

    verbose = mkOption {
      description = "Kubernetes enable verbose mode for debugging";
      default = false;
      type = types.bool;
    };

    etcd = {
      servers = mkOption {
        description = "List of etcd servers. By default etcd is started, except if this option is changed.";
        default = ["http://127.0.0.1:2379"];
        type = types.listOf types.str;
      };

      keyFile = mkOption {
        description = "Etcd key file";
        default = null;
        type = types.nullOr types.path;
      };

      certFile = mkOption {
        description = "Etcd cert file";
        default = null;
        type = types.nullOr types.path;
      };

      caFile = mkOption {
        description = "Etcd ca file";
        default = null;
        type = types.nullOr types.path;
      };
    };

    master = mkOption {
      description = "Kubernetes apiserver address";
      default = "${cfg.apiserver.address}:${toString cfg.apiserver.port}";
      type = types.str;
    };

    kubeconfig = {
      caFile = mkOption {
        description = "Certificate authrority file to use to connect to kuberentes apiserver";
        type = types.nullOr types.str;
        default = null;
      };

      certFile = mkOption {
        description = "Client certificate file to use to connect to kubernetes";
        type = types.nullOr types.str;
        default = null;
      };

      keyFile = mkOption {
        description = "Client key file to use to connect to kubernetes";
        type = types.nullOr types.str;
        default = null;
      };
    };

    dataDir = mkOption {
      description = "Kubernetes root directory for managing kubelet files.";
      default = "/var/lib/kubernetes";
      type = types.path;
    };

    dockerCfg = mkOption {
      description = "Kubernetes contents of dockercfg file.";
      default = "";
      type = types.lines;
    };

    apiserver = {
      enable = mkOption {
        description = "Whether to enable kubernetes apiserver.";
        default = false;
        type = types.bool;
      };

      address = mkOption {
        description = "Kubernetes apiserver listening address.";
        default = "127.0.0.1";
        type = types.str;
      };

      publicAddress = mkOption {
        description = ''
          Kubernetes apiserver public listening address used for read only and
          secure port.
        '';
        default = cfg.apiserver.address;
        type = types.str;
      };

      advertiseAddress = mkOption {
        description = ''
          Kubernetes apiserver IP address on which to advertise the apiserver
          to members of the cluster. This address must be reachable by the rest
          of the cluster.
        '';
        default = "192.168.1.1";
        type = types.nullOr types.str;
      };

      port = mkOption {
        description = "Kubernetes apiserver listening port.";
        default = 8080;
        type = types.int;
      };

      securePort = mkOption {
        description = "Kubernetes apiserver secure port.";
        default = 443;
        type = types.int;
      };

      tlsCertFile = mkOption {
        description = "Kubernetes apiserver certificate file.";
        default = null;
        type = types.nullOr types.str;
      };

      tlsKeyFile = mkOption {
        description = "Kubernetes apiserver private key file.";
        default = null;
        type = types.nullOr types.str;
      };

      clientCaFile = mkOption {
        description = "Kubernetes apiserver CA file for client auth.";
        default = null;
        type = types.nullOr types.str;
      };

      tokenAuth = mkOption {
        description = ''
          Kubernetes apiserver token authentication file. See
          <link xlink:href="http://kubernetes.io/docs/admin/authentication.html"/>
        '';
        default = null;
        example = ''token,user,uid,"group1,group2,group3"'';
        type = types.nullOr types.lines;
      };

      authorizationMode = mkOption {
        description = ''
          Kubernetes apiserver authorization mode (AlwaysAllow/AlwaysDeny/ABAC). See
          <link xlink:href="http://kubernetes.io/v1.0/docs/admin/authorization.html"/>
        '';
        default = "AlwaysAllow";
        type = types.enum ["AlwaysAllow" "AlwaysDeny" "ABAC"];
      };

      authorizationPolicy = mkOption {
        description = ''
          Kubernetes apiserver authorization policy file. See
          <link xlink:href="http://kubernetes.io/v1.0/docs/admin/authorization.html"/>
        '';
        default = [];
        example = literalExample ''
          [
            {user = "admin";}
            {user = "scheduler"; readonly = true; kind= "pods";}
            {user = "scheduler"; kind = "bindings";}
            {user = "kubelet";  readonly = true; kind = "bindings";}
            {user = "kubelet"; kind = "events";}
            {user= "alice"; ns = "projectCaribou";}
            {user = "bob"; readonly = true; ns = "projectCaribou";}
          ]
        '';
        type = types.listOf types.attrs;
      };

      allowPrivileged = mkOption {
        description = "Whether to allow privileged containers on kubernetes.";
        default = true;
        type = types.bool;
      };

      portalNet = mkOption {
        description = "Kubernetes CIDR notation IP range from which to assign portal IPs";
        default = "10.10.10.10/24";
        type = types.str;
      };

      runtimeConfig = mkOption {
        description = ''
          Api runtime configuration. See
          <link xlink:href="http://kubernetes.io/v1.0/docs/admin/cluster-management.html"/>
        '';
        default = "";
        example = "api/all=false,api/v1=true";
        type = types.str;
      };

      admissionControl = mkOption {
        description = ''
          Kubernetes admission control plugins to use. See
          <link xlink:href="http://kubernetes.io/docs/admin/admission-controllers/"/>
        '';
        default = ["NamespaceLifecycle" "LimitRanger" "ServiceAccount" "ResourceQuota"];
        example = [
          "NamespaceLifecycle" "NamespaceExists" "LimitRanger"
          "SecurityContextDeny" "ServiceAccount" "ResourceQuota"
        ];
        type = types.listOf types.str;
      };

      serviceAccountKeyFile = mkOption {
        description = ''
          Kubernetes apiserver PEM-encoded x509 RSA private or public key file,
          used to verify ServiceAccount tokens.
        '';
        default = null;
        type = types.nullOr types.path;
      };

      kubeletClientCaFile = mkOption {
        description = "Path to a cert file for connecting to kubelet";
        default = null;
        type = types.nullOr types.path;
      };

      kubeletClientCertFile = mkOption {
        description = "Client certificate to use for connections to kubelet";
        default = null;
        type = types.nullOr types.path;
      };

      kubeletClientKeyFile = mkOption {
        description = "Key to use for connections to kubelet";
        default = null;
        type = types.nullOr types.path;
      };

      kubeletHttps = mkOption {
        description = "Whether to use https for connections to kubelet";
        default = true;
        type = types.bool;
      };

      extraOpts = mkOption {
        description = "Kubernetes apiserver extra command line options.";
        default = [];
        type = types.listOf types.str;
      };
    };

    scheduler = {
      enable = mkOption {
        description = "Whether to enable kubernetes scheduler.";
        default = false;
        type = types.bool;
      };

      address = mkOption {
        description = "Kubernetes scheduler listening address.";
        default = "127.0.0.1";
        type = types.str;
      };

      port = mkOption {
        description = "Kubernetes scheduler listening port.";
        default = 10251;
        type = types.int;
      };

      leaderElect = mkOption {
        description = "Whether to start leader election before executing main loop";
        type = types.bool;
        default = false;
      };

      extraOpts = mkOption {
        description = "Kubernetes scheduler extra command line options.";
        default = [];
        type = types.listOf types.str;
      };
    };

    controllerManager = {
      enable = mkOption {
        description = "Whether to enable kubernetes controller manager.";
        default = false;
        type = types.bool;
      };

      address = mkOption {
        description = "Kubernetes controller manager listening address.";
        default = "127.0.0.1";
        type = types.str;
      };

      port = mkOption {
        description = "Kubernetes controller manager listening port.";
        default = 10252;
        type = types.int;
      };

      leaderElect = mkOption {
        description = "Whether to start leader election before executing main loop";
        type = types.bool;
        default = false;
      };

      serviceAccountKeyFile = mkOption {
        description = ''
          Kubernetes controller manager PEM-encoded private RSA key file used to
          sign service account tokens
        '';
        default = null;
        type = types.nullOr types.path;
      };

      rootCaFile = mkOption {
        description = ''
          Kubernetes controller manager certificate authority file included in
          service account's token secret.
        '';
        default = null;
        type = types.nullOr types.path;
      };

      clusterCidr = mkOption {
        description = "Kubernetes controller manager CIDR Range for Pods in cluster";
        default = "10.10.0.0/16";
        type = types.str;
      };

      extraOpts = mkOption {
        description = "Kubernetes controller manager extra command line options.";
        default = [];
        type = types.listOf types.str;
      };
    };

    kubelet = {
      enable = mkOption {
        description = "Whether to enable kubernetes kubelet.";
        default = false;
        type = types.bool;
      };

      infraContainerImage = mkOption {
        description = "Name of the infra container image to use (by default uses one build by nix)";
        default = "pause:${packageHash cfg.package.pause}";
        type = types.str;
      };

      registerNode = mkOption {
        description = "Whether to auto register kubelet with API server.";
        default = true;
        type = types.bool;
      };

      registerSchedulable = mkOption {
        description = "Register the node as schedulable. No-op if register-node is false.";
        default = true;
        type = types.bool;
      };

      address = mkOption {
        description = "Kubernetes kubelet info server listening address.";
        default = "0.0.0.0";
        type = types.str;
      };

      port = mkOption {
        description = "Kubernetes kubelet info server listening port.";
        default = 10250;
        type = types.int;
      };

      healthz = {
        bind = mkOption {
          description = "Kubernetes kubelet healthz listening address.";
          default = "127.0.0.1";
          type = types.str;
        };

        port = mkOption {
          description = "Kubernetes kubelet healthz port.";
          default = 10248;
          type = types.int;
        };
      };

      hostname = mkOption {
        description = "Kubernetes kubelet hostname override";
        default = config.networking.hostName;
        type = types.str;
      };

      allowPrivileged = mkOption {
        description = "Whether to allow kubernetes containers to request privileged mode.";
        default = false;
        type = types.bool;
      };

      apiServers = mkOption {
        description = ''
          Kubernetes kubelet list of Kubernetes API servers for publishing events,
          and reading pods and services.
        '';
        default = [cfg.master];
        type = types.listOf types.str;
      };

      cadvisorPort = mkOption {
        description = "Kubernetes kubelet local cadvisor port.";
        default = 4194;
        type = types.int;
      };

      clusterDns = mkOption {
        description = "Use alternative dns.";
        default = "";
        type = types.str;
      };

      clusterDomain = mkOption {
        description = "Use alternative domain.";
        default = "cluster.local";
        type = types.str;
      };

      networkPlugin = mkOption {
        description = "Network plugin to use by kubernetes";
        type = types.nullOr (types.enum ["cni" "kubenet"]);
        default = null;
      };

      networkPluginDir = mkOption {
        description = "Directory where to read network plugin config";
        type = types.path;
        default = "/etc/cni/net.d";
      };

      cniPluginPackages = mkOption {
        description = "List of network plugin packages to install";
        type = types.listOf types.package;
        default = [];
      };

      manifests = mkOption {
        description = "List of manifests to bootstrap with kubelet";
        type = types.attrsOf types.attrs;
        default = {};
      };

      extraOpts = mkOption {
        description = "Kubernetes kubelet extra command line options.";
        default = "";
        type = types.str;
      };
    };

    proxy = {
      enable = mkOption {
        description = "Whether to enable kubernetes proxy.";
        default = false;
        type = types.bool;
      };

      address = mkOption {
        description = "Kubernetes proxy listening address.";
        default = "0.0.0.0";
        type = types.str;
      };

      extraOpts = mkOption {
        description = "Kubernetes proxy extra command line options.";
        default = [];
        type = types.listOf types.str;
      };
    };

    dns = {
      enable = mkEnableOption "kubernetes dns service.";

      port = mkOption {
        description = "Kubernetes dns listening port";
        default = 53;
        type = types.int;
      };

      domain = mkOption  {
        description = "Kuberntes dns domain under which to create names.";
        default = cfg.kubelet.clusterDomain;
        type = types.str;
      };

      extraOpts = mkOption {
        description = "Kubernetes dns extra command line options.";
        default = [];
        type = types.listOf types.str;
      };
    };

    calico = {
      enable = mkEnableOption "Enable calico network plugin";

      image = mkOption {
        description = "Image to use for calico policy controller";
        type = types.str;
        default = "calico-k8s-policy:${packageHash pkgs.calico-k8s-policy}";
      };
    };
  };

  ###### implementation

  config = mkMerge [
    (mkIf cfg.kubelet.enable {
      systemd.services.kube-load-containers = {
        description = "Kubernetes Load Containers";
        wantedBy = ["multi-user.target"];
        after = ["docker.service"];
        path = [ pkgs.docker ];
        script = ''
          docker load < ${infraContainer}
          docker load < ${kubernetesContainer}
          docker load < ${calicoK8SPolicyContainer}
        '';
        serviceConfig.Type = "oneshot";
      };

      systemd.services.kubelet = {
        description = "Kubernetes Kubelet Service";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-interfaces.target" "docker.service" "kube-load-containers" ];
        path = with pkgs; [ gitMinimal openssh docker utillinux iproute ethtool ];
        preStart = ''
          rm ${cfg.dataDir}/.dockercfg || true
          ln -fs ${pkgs.writeText "kubernetes-dockercfg" cfg.dockerCfg} ${cfg.dataDir}/.dockercfg
          rm /opt/cni/bin/* || true
          ${concatMapStringsSep "\n" (p: "ln -fs ${p.plugins}/* /opt/cni/bin") cfg.kubelet.cniPluginPackages}
        '';
        serviceConfig = {
          ExecStart = ''${cfg.package}/bin/hyperkube kubelet \
            --config /etc/kubernetes/manifests \
            --api-servers=${concatStringsSep "," cfg.kubelet.apiServers}  \
            --register-node=${if cfg.kubelet.registerNode then "true" else "false"} \
            --register-schedulable=${if cfg.kubelet.registerSchedulable then "true" else "false"} \
            --address=${cfg.kubelet.address} \
            --port=${toString cfg.kubelet.port} \
            --healthz-bind-address=${cfg.kubelet.healthz.bind} \
            --healthz-port=${toString cfg.kubelet.healthz.port} \
            --hostname-override=${cfg.kubelet.hostname} \
            --allow-privileged=${if cfg.kubelet.allowPrivileged then "true" else "false"} \
            --root-dir=${cfg.dataDir} \
            --cadvisor_port=${toString cfg.kubelet.cadvisorPort} \
            ${optionalString (cfg.kubelet.clusterDns != "")
              ''--cluster-dns=${cfg.kubelet.clusterDns}''} \
            ${optionalString (cfg.kubelet.clusterDomain != "")
              ''--cluster-domain=${cfg.kubelet.clusterDomain}''} \
            --pod-infra-container-image=${cfg.kubelet.infraContainerImage} \
            ${optionalString (cfg.kubelet.networkPlugin != null)
              ''--network-plugin=${cfg.kubelet.networkPlugin}''} \
            --network-plugin-dir=${cfg.kubelet.networkPluginDir} \
            --logtostderr=true \
            ${optionalString cfg.verbose "--v=6 --log_flush_frequency=1s"} \
            ${cfg.kubelet.extraOpts}
          '';
          WorkingDirectory = cfg.dataDir;
        };
      };

      environment.etc = mapAttrs' (name: manifest:
        nameValuePair "kubernetes/manifests/${name}.json" {
          text = builtins.toJSON manifest;
          mode = "0755";
        }
      ) cfg.kubelet.manifests;

      # Allways include cni plugins
      services.kubernetes.kubelet.cniPluginPackages =
        mkIf (cfg.kubelet.networkPlugin == "cni") [pkgs.cni];

      systemd.tmpfiles.rules = ["d /opt/cni/bin 0755 root root -"];
    })

    (mkIf cfg.apiserver.enable {
      services.kubernetes.kubelet.manifests.kube-apiserver = {
        apiVersion = "v1";
        kind = "Pod";
        metadata = {
          name = "kube-apiserver";
          namespace = "kube-system";
        };
        spec = {
          hostNetwork = true;
          containers = [{
            name = "kube-apiserver";
            image = cfg.image;
            command = [
              "/bin/hyperkube"
              "apiserver"
              "--etcd-servers=${concatStringsSep "," cfg.etcd.servers}"
              (optionalString (cfg.etcd.caFile != null)
                "--etcd-cafile=/var/run/kubernetes/ssl/etcd-ca.pem")
              (optionalString (cfg.etcd.certFile != null)
                "--etcd-certfile=/var/run/kubernetes/ssl/etcd.pem")
              (optionalString (cfg.etcd.keyFile != null)
                "--etcd-keyfile=/var/run/kubernetes/ssl/etcd-key.pem")
              "--insecure-port=${toString cfg.apiserver.port}"
              "--bind-address=0.0.0.0"
              (optionalString (cfg.apiserver.advertiseAddress != null)
                "--advertise-address=${cfg.apiserver.advertiseAddress}")
              ("--allow-privileged=${if cfg.apiserver.allowPrivileged then "true" else "false"}")
              (optionalString (cfg.apiserver.tlsCertFile!=null)
                "--tls-cert-file=/var/run/kubernetes/ssl/apiserver.pem")
              (optionalString (cfg.apiserver.tlsKeyFile!=null)
                "--tls-private-key-file=/var/run/kubernetes/ssl/apiserver-key.pem")
              (optionalString (cfg.apiserver.tokenAuth!=null)
                "--token-auth-file=/var/run/kubernetes/token-auth")
              "--kubelet-https=${if cfg.apiserver.kubeletHttps then "true" else "false"}"
              (optionalString (cfg.apiserver.kubeletClientCaFile != null)
                "--kubelet-certificate-authority=/var/run/kubernetes/ssl/kubelet-client-ca.pem")
              (optionalString (cfg.apiserver.kubeletClientCertFile != null)
                "--kubelet-client-certificate=/var/run/kubernetes/ssl/kubelet-client.pem")
              (optionalString (cfg.apiserver.kubeletClientKeyFile != null)
                "--kubelet-client-key=/var/run/kubernetes/ssl/kubelet-client-key.pem")
              (optionalString (cfg.apiserver.clientCaFile != null)
                "--client-ca-file=/var/run/kubernetes/ssl/client-ca.pem")
              "--authorization-mode=${cfg.apiserver.authorizationMode}"
              (optionalString (cfg.apiserver.authorizationMode == "ABAC")
                "--authorization-policy-file=/var/run/kubernetes/policy")
              "--secure-port=${toString cfg.apiserver.securePort}"
              "--service-cluster-ip-range=${cfg.apiserver.portalNet}"
              (optionalString (cfg.apiserver.runtimeConfig!="")
                "--runtime-config=${cfg.apiserver.runtimeConfig}")
              "--admission_control=${concatStringsSep "," cfg.apiserver.admissionControl}"
              (optionalString (cfg.apiserver.serviceAccountKeyFile!=null)
                "--service-account-key-file=/var/run/kubernetes/ssl/service-account.pem")
              (optionalString cfg.verbose "--v=6")
              (optionalString cfg.verbose "--log-flush-frequency=1s")
            ] ++ cfg.apiserver.extraOpts;
            ports = [{
              containerPort = cfg.apiserver.securePort;
              hostPort = cfg.apiserver.securePort;
              name = "https";
            } {
              containerPort = cfg.apiserver.port;
              hostPort = cfg.apiserver.port;
              name = "local";
            }];
            volumeMounts = skipAttrs [{
              mountPath = "/var/run/kubernetes";
              name = "run";
            } {
              enable = cfg.apiserver.tokenAuth != null;
              mountPath = "/var/run/kubernetes/token-auth";
              name = "kube-token-auth";
              readOnly = true;
            } {
              enable = cfg.apiserver.authorizationMode == "ABAC";
              mountPath = "/var/run/kubernetes/policy";
              name = "policy";
              readOnly = true;
            } {
              enable = cfg.apiserver.serviceAccountKeyFile != null;
              mountPath = "/var/run/kubernetes/service-account.pem";
              name = "service-account-key";
              readOnly = true;
            } {
              enable = cfg.apiserver.tlsCertFile != null;
              mountPath = "/var/run/kubernetes/ssl/apiserver.pem";
              name = "tls-cert";
              readOnly = true;
            } {
              enable = cfg.apiserver.tlsKeyFile != null;
              mountPath = "/var/run/kubernetes/ssl/apiserver-key.pem";
              name = "tls-private-key";
              readOnly = true;
            } {
              enable = cfg.etcd.caFile != null;
              mountPath = "/var/run/kubernetes/ssl/etcd-ca.pem";
              name = "etcd-ca";
              readOnly = true;
            } {
              enable = cfg.etcd.certFile != null;
              mountPath = "/var/run/kubernetes/ssl/etcd.pem";
              name = "etcd-cert";
              readOnly = true;
            } {
              enable = cfg.etcd.keyFile != null;
              mountPath = "/var/run/kubernetes/ssl/etcd-key.pem";
              name = "etcd-key";
              readOnly = true;
            } {
              enable = cfg.apiserver.kubeletClientCaFile != null;
              mountPath = "/var/run/kubernetes/ssl/kubelet-client-ca.pem";
              name = "kubelet-client-ca";
              readOnly = true;
            } {
              enable = cfg.apiserver.kubeletClientCertFile != null;
              mountPath = "/var/run/kubernetes/ssl/kubelet-client.pem";
              name = "kubelet-client-cert";
              readOnly = true;
            } {
              enable = cfg.apiserver.kubeletClientKeyFile != null;
              mountPath = "/var/run/kubernetes/ssl/kubelet-client-key.pem";
              name = "kubelet-client-key";
              readOnly = true;
            } {
              enable = cfg.apiserver.clientCaFile != null;
              mountPath = "/var/run/kubernetes/ssl/client-ca.pem";
              name = "client-ca";
              readOnly = true;
            }];
          }];
          volumes = skipAttrs [{
            hostPath.path = "/var/run/kubernetes";
            name = "run";
          } {
            enable = cfg.apiserver.tokenAuth != null;
            hostPath.path = cfg.apiserver.tokenAuth;
            name = "token-auth";
          } {
            enable = cfg.apiserver.authorizationMode == "ABAC";
            hostPath.path = pkgs.writeText "kube-policy"
              concatStringsSep "\n" (map (builtins.toJSON cfg.apiserver.authorizationPolicy));
            name = "policy";
          } {
            enable = cfg.apiserver.serviceAccountKeyFile != null;
            hostPath.path = cfg.apiserver.serviceAccountKeyFile;
            name = "service-account-key";
          } {
            enable = cfg.apiserver.tlsCertFile != null;
            hostPath.path = cfg.apiserver.tlsCertFile;
            name = "tls-cert";
          } {
            enable = cfg.apiserver.tlsKeyFile != null;
            hostPath.path = cfg.apiserver.tlsKeyFile;
            name = "tls-private-key";
          } {
            enable = cfg.etcd.caFile != null;
            hostPath.path = cfg.etcd.caFile;
            name = "etcd-ca";
          } {
            enable = cfg.etcd.certFile != null;
            hostPath.path = cfg.etcd.certFile;
            name = "etcd-cert";
          } {
            enable = cfg.etcd.keyFile != null;
            hostPath.path = cfg.etcd.keyFile;
            name = "etcd-key";
          } {
            enable = cfg.apiserver.kubeletClientCaFile != null;
            hostPath.path = cfg.apiserver.kubeletClientCaFile;
            name = "kubelet-client-ca";
          } {
            enable = cfg.apiserver.kubeletClientCertFile != null;
            hostPath.path = cfg.apiserver.kubeletClientCertFile;
            name = "kubelet-client-cert";
          } {
            enable = cfg.apiserver.kubeletClientKeyFile != null;
            hostPath.path = cfg.apiserver.kubeletClientKeyFile;
            name = "kubelet-client-key";
          } {
            enable = cfg.apiserver.clientCaFile != null;
            hostPath.path = cfg.apiserver.clientCaFile;
            name = "client-ca";
          }];
        };
      };
    })

    (mkIf cfg.scheduler.enable {
      services.kubernetes.kubelet.manifests.kube-scheduler = {
        apiVersion = "v1";
        kind = "Pod";
        metadata = {
          name = "kube-scheduler";
          namespace = "kube-system";
        };
        spec = {
          hostNetwork = true;
          containers = [{
            name = "kube-scheduler";
            image = cfg.image;
            command = [
              "/bin/hyperkube"
              "scheduler"
              "--address=${cfg.scheduler.address}"
              "--port=${toString cfg.scheduler.port}"
              "--master=${cfg.master}"
              "--leader-elect=${if cfg.scheduler.leaderElect then "true" else "false"}"
              (optionalString kubeconfigDefined "--kubeconfig=/etc/kubernetes/kubeconfig")
              "--logtostderr=true"
              (optionalString cfg.verbose "--v=6")
              (optionalString cfg.verbose "--log-flush-frequency=1s")

            ] ++ cfg.scheduler.extraOpts;
            livenessProbe = {
              httpGet = {
                host = cfg.scheduler.address;
                path = "/healthz";
                port = cfg.scheduler.port;
              };
              initialDelaySeconds = 15;
              timeoutSeconds = 1;
            };
            volumeMounts = skipAttrs [{
              mountPath = "/var/run/kubernetes";
              name = "run";
            } {
              enable = kubeconfigDefined;
              mountPath = "/etc/kubernetes/kubeconfig";
              name = "kubeconfig";
              readOnly = true;
            } {
              enable = kubeconfigDefined;
              mountPath = cfg.kubeconfig.caFile;
              name = "kubeconfig-ca";
              readOnly = true;
            } {
              enable = kubeconfigDefined;
              mountPath = cfg.kubeconfig.certFile;
              name = "kubeconfig-cert";
              readOnly = true;
            } {
              enable = kubeconfigDefined;
              mountPath = cfg.kubeconfig.keyFile;
              name = "kubeconfig-cert";
              readOnly = true;
            }];
          }];
          volumes = skipAttrs [{
            hostPath.path = "/var/run/kubernetes";
            name = "run";
          } {
            enable = kubeconfigDefined;
            hostPath.path = kubeconfig;
            name = "kubeconfig";
          } {
            enable = kubeconfigDefined;
            hostPath.path = cfg.kubeconfig.caFile;
            name = "kubeconfig-ca";
          } {
            enable = kubeconfigDefined;
            hostPath.path = cfg.kubeconfig.certFile;
            name = "kubeconfig-cert";
          } {
            enable = kubeconfigDefined;
            hostPath.path = cfg.kubeconfig.keyFile;
            name = "kubeconfig-key";
          }];
        };
      };
    })

    (mkIf cfg.controllerManager.enable {
      services.kubernetes.kubelet.manifests.kube-controller-manager = {
        apiVersion = "v1";
        kind = "Pod";
        metadata = {
          name = "kube-controller-manager";
          namespace = "kube-system";
        };
        spec = {
          hostNetwork = true;
          containers = [{
            name = "kube-controller-manager";
            image = cfg.image;
            command = [
              "/bin/hyperkube"
              "controller-manager"
              "--address=${cfg.controllerManager.address}"
              "--port=${toString cfg.controllerManager.port}"
              "--master=${cfg.master}"
              (optionalString kubeconfigDefined "--kubeconfig=/etc/kubernetes/kubeconfig")
              "--leader-elect=${if cfg.controllerManager.leaderElect then "true" else "false"}"
              (if (cfg.controllerManager.serviceAccountKeyFile!=null)
                then "--service-account-private-key-file=/var/run/kubernetes/ssl/service-account-key.pem"
                else "--service-account-private-key-file=/var/run/kubernetes/apiserver.key")
              (optionalString (cfg.controllerManager.rootCaFile!=null)
                "--root-ca-file=/var/run/kubernetes/ssl/ca.pem")
              (optionalString (cfg.controllerManager.clusterCidr!=null)
                "--cluster-cidr=${cfg.controllerManager.clusterCidr}")
              "--allocate-node-cidrs=true"
              "--logtostderr=true"
              (optionalString cfg.verbose "--v=6")
              (optionalString cfg.verbose "--log-flush-frequency=1s")
            ] ++ cfg.scheduler.extraOpts;
            livenessProbe = {
              httpGet = {
                host = cfg.controllerManager.address;
                path = "/healthz";
                port = cfg.controllerManager.port;
              };
              initialDelaySeconds = 15;
              timeoutSeconds = 1;
            };
            volumeMounts = skipAttrs [{
              mountPath = "/var/run/kubernetes";
              name = "run";
            } {
              enable = cfg.controllerManager.serviceAccountKeyFile != null;
              mountPath = "/var/run/kubernetes/ssl/service-account-key.pem";
              name = "service-account-key";
              readOnly = true;
            } {
              enable = cfg.controllerManager.rootCaFile != null;
              mountPath = "/var/run/kubernetes/ssl/ca.pem";
              name = "ca";
              readOnly = true;
            } {
              enable = kubeconfigDefined;
              mountPath = "/etc/kubernetes/kubeconfig";
              name = "kubeconfig";
              readOnly = true;
            } {
              enable = kubeconfigDefined;
              mountPath = cfg.kubeconfig.caFile;
              name = "kubeconfig-ca";
              readOnly = true;
            } {
              enable = kubeconfigDefined;
              mountPath = cfg.kubeconfig.certFile;
              name = "kubeconfig-cert";
              readOnly = true;
            } {
              enable = kubeconfigDefined;
              mountPath = cfg.kubeconfig.keyFile;
              name = "kubeconfig-cert";
              readOnly = true;
            }];
          }];
          volumes = skipAttrs [{
            hostPath.path = "/var/run/kubernetes";
            name = "run";
          } {
            enable = cfg.controllerManager.serviceAccountKeyFile != null;
            hostPath.path = cfg.controllerManager.serviceAccountKeyFile;
            name = "service-account-key";
          } {
            enable = cfg.controllerManager.rootCaFile != null;
            hostPath.path = cfg.controllerManager.rootCaFile;
            name = "ca";
          } {
            enable = kubeconfigDefined;
            hostPath.path = kubeconfig;
            name = "kubeconfig";
          } {
            enable = kubeconfigDefined;
            hostPath.path = cfg.kubeconfig.caFile;
            name = "kubeconfig-ca";
          } {
            enable = kubeconfigDefined;
            hostPath.path = cfg.kubeconfig.certFile;
            name = "kubeconfig-cert";
          } {
            enable = kubeconfigDefined;
            hostPath.path = cfg.kubeconfig.keyFile;
            name = "kubeconfig-key";
          }];
        };
      };
    })

    (mkIf cfg.proxy.enable {
      services.kubernetes.kubelet.manifests.kube-proxy = {
        apiVersion = "v1";
        kind = "Pod";
        metadata = {
          name = "kube-proxy";
          namespace = "kube-system";
        };
        spec = {
          hostNetwork = true;
          containers = [{
            name = "kube-proxy";
            image = cfg.image;
            command = [
              "/bin/hyperkube"
              "proxy"
              "--master=${cfg.master}"
              (optionalString kubeconfigDefined "--kubeconfig=/etc/kubernetes/kubeconfig")
              "--bind-address=${cfg.proxy.address}"
              "--logtostderr=true"
              (optionalString cfg.verbose "--v=6")
              (optionalString cfg.verbose "--log-flush-frequency=1s")
            ] ++ cfg.proxy.extraOpts;
            securityContext.privileged = true;
            volumeMounts = skipAttrs [{
              mountPath = "/tmp";
              name = "tmp";
            } {
              enable = kubeconfigDefined;
              mountPath = "/etc/kubernetes/kubeconfig";
              name = "kubeconfig";
              readOnly = true;
            } {
              enable = kubeconfigDefined;
              mountPath = cfg.kubeconfig.caFile;
              name = "kubeconfig-ca";
              readOnly = true;
            } {
              enable = kubeconfigDefined;
              mountPath = cfg.kubeconfig.certFile;
              name = "kubeconfig-cert";
              readOnly = true;
            } {
              enable = kubeconfigDefined;
              mountPath = cfg.kubeconfig.keyFile;
              name = "kubeconfig-cert";
              readOnly = true;
            }];
          }];
          volumes = skipAttrs [{
            name = "tmp";
            emptyDir.medium = "Memory";
          } {
            enable = kubeconfigDefined;
            hostPath.path = kubeconfig;
            name = "kubeconfig";
          } {
            enable = kubeconfigDefined;
            hostPath.path = cfg.kubeconfig.caFile;
            name = "kubeconfig-ca";
          } {
            enable = kubeconfigDefined;
            hostPath.path = cfg.kubeconfig.certFile;
            name = "kubeconfig-cert";
          } {
            enable = kubeconfigDefined;
            hostPath.path = cfg.kubeconfig.keyFile;
            name = "kubeconfig-key";
          }];
        };
      };
    })

    (mkIf cfg.dns.enable {
      services.kubernetes.kubelet.manifests.kube-dns = {
        apiVersion = "v1";
        kind = "Pod";
        metadata = {
          name = "kube-dns";
          namespace = "kube-system";
        };
        spec = {
          hostNetwork = true;
          containers = [{
            name = "kube-dns";
            image = cfg.image;
            command = [
              "/bin/kube-dns"
              "--kube-master-url=http://${cfg.master}"
              (optionalString kubeconfigDefined "--kubecfg-file=/etc/kubernetes/kubeconfig")
              "--dns-port=${toString cfg.dns.port}"
              "--domain=${cfg.dns.domain}"
              "--logtostderr=true"
              (optionalString cfg.verbose "--v=6")
              (optionalString cfg.verbose "--log-flush-frequency=1s")
            ] ++ cfg.dns.extraOpts;
            securityContext.privileged = true;
            volumeMounts = skipAttrs [{
              enable = kubeconfigDefined;
              mountPath = "/etc/kubernetes/kubeconfig";
              name = "kubeconfig";
              readOnly = true;
            } {
              enable = kubeconfigDefined;
              mountPath = cfg.kubeconfig.caFile;
              name = "kubeconfig-ca";
              readOnly = true;
            } {
              enable = kubeconfigDefined;
              mountPath = cfg.kubeconfig.certFile;
              name = "kubeconfig-cert";
              readOnly = true;
            } {
              enable = kubeconfigDefined;
              mountPath = cfg.kubeconfig.keyFile;
              name = "kubeconfig-cert";
              readOnly = true;
            }];
          }];
          volumes = skipAttrs [{
            enable = kubeconfigDefined;
            hostPath.path = kubeconfig;
            name = "kubeconfig";
          } {
            enable = kubeconfigDefined;
            hostPath.path = cfg.kubeconfig.caFile;
            name = "kubeconfig-ca";
          } {
            enable = kubeconfigDefined;
            hostPath.path = cfg.kubeconfig.certFile;
            name = "kubeconfig-cert";
          } {
            enable = kubeconfigDefined;
            hostPath.path = cfg.kubeconfig.keyFile;
            name = "kubeconfig-key";
          }];
        };
      };
    })

    (mkIf cfg.calico.enable {
      services.kubernetes.kubelet.manifests.calico-policy-manager = {
        apiVersion = "v1";
        kind = "Pod";
        metadata = {
          name = "calico-policy-controller";
          namespace = "kube-system";
        };
        spec = {
          hostNetwork = true;
          containers = [{
            name = "calico-policy-controller";
            image = cfg.calico.image;
            env = skipAttrs [{
              name = "K8S_API";
              value = "http://" + cfg.master;
            } {
              name = "ETCD_ENDPOINTS";
              value = concatStringsSep "," cfg.etcd.servers;
            } {
              enable = cfg.etcd.caFile != null;
              name = "ETCD_CA_FILE";
              value = "/var/lib/kubernetes/ssl/etcd-ca.pem";
            } {
              enable = cfg.etcd.keyFile != null;
              name = "ETCD_KEY_FILE";
              value = "/var/lib/kubernetes/ssl/etcd-key.pem";
            } {
              enable = cfg.etcd.certFile != null;
              name = "ETCD_CERT_FILE";
              value = "/var/lib/kubernetes/ssl/etcd.pem";
            }];
            volumeMounts = skipAttrs [{
              enable = cfg.etcd.caFile != null;
              mountPath = "/var/lib/kubernetes/ssl/etcd-ca.pem";
              name = "etcd-ca";
              readOnly = true;
            } {
              enable = cfg.etcd.certFile != null;
              mountPath = "/var/lib/kubernetes/ssl/etcd.pem";
              name = "etcd-cert";
              readOnly = true;
            } {
              enable = cfg.etcd.keyFile != null;
              mountPath = "/var/lib/kubernetes/ssl/etcd-key.pem";
              name = "etcd-key";
              readOnly = true;
            }];
          }];
          volumes = skipAttrs [{
            enable = cfg.etcd.caFile != null;
            hostPath.path = cfg.etcd.caFile;
            name = "etcd-ca";
          } {
            enable = cfg.etcd.certFile != null;
            hostPath.path = cfg.etcd.certFile;
            name = "etcd-cert";
          } {
            enable = cfg.etcd.keyFile != null;
            hostPath.path = cfg.etcd.keyFile;
            name = "etcd-key";
          }];
        };
      };

      services.kubernetes.kubelet.networkPlugin = "cni";
      services.kubernetes.kubelet.cniPluginPackages = [pkgs.calico-cni];
      services.calico.enable = mkDefault true;

      environment.etc."cni/net.d/10-calico.conf".text = builtins.toJSON {
        name = "calico-k8s-network";
        type = "calico";
        etcd_endpoints = concatStringsSep "," cfg.etcd.servers;
        etcd_key_file = cfg.etcd.keyFile;
        etcd_cert_file = cfg.etcd.certFile;
        etcd_ca_cert_file = cfg.etcd.caFile;
        log_level = "info";
        policy = {
          type = "k8s";
        };
        kubernetes = {
          k8s_api_root = "http://${cfg.master}";
          kubeconfig = kubeconfig;
        };
        ipam = {
          type = "host-local";
          subnet = "usePodCidr";
        };
      };
    })

    (mkIf (any (el: el == "master") cfg.roles) {
      virtualisation.docker.enable = mkDefault true;
      services.kubernetes.kubelet.enable = mkDefault true;
      services.kubernetes.kubelet.allowPrivileged = mkDefault true;
      services.kubernetes.kubelet.registerSchedulable = mkOverride 1000 false;
      services.kubernetes.apiserver.enable = mkDefault true;
      services.kubernetes.scheduler.enable = mkDefault true;
      services.kubernetes.controllerManager.enable = mkDefault true;
      services.etcd.enable = mkDefault (cfg.etcd.servers == ["http://127.0.0.1:2379"]);
    })

    (mkIf (any (el: el == "node") cfg.roles) {
      virtualisation.docker.enable = mkDefault true;
      services.kubernetes.kubelet.enable = mkDefault true;
      services.kubernetes.proxy.enable = mkDefault true;
      services.kubernetes.dns.enable = mkDefault true;
    })

    (mkIf (
        cfg.apiserver.enable ||
        cfg.scheduler.enable ||
        cfg.controllerManager.enable ||
        cfg.kubelet.enable ||
        cfg.proxy.enable ||
        cfg.dns.enable
    ) {
      systemd.tmpfiles.rules = [
        "d /run/kubernetes 0755 root root -"
        "d /var/lib/kubernetes 0755 root root -"
      ];

      environment.systemPackages = [ cfg.package ];
    })
  ];
}
