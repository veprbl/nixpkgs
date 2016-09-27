{ system ? builtins.currentSystem }:

with import ../lib/testing.nix { inherit system; };
with import ../lib/qemu-flags.nix;
with pkgs.lib;

let
  redisPod = pkgs.writeText "redis-master-pod.yaml" ''
    kind: Pod
    apiVersion: v1
    metadata:
      name: 'redis'
      labels:
        app: redis
        role: master
    spec:
      containers:
      - name: master
        image: redis
        args: ["--bind", "0.0.0.0"]
        imagePullPolicy: Never
        ports:
        - name: redis-server
          containerPort: 6379
  '';

  redisService = pkgs.writeText "redis-service.yaml" ''
    kind: Service
    apiVersion: v1
    metadata:
      name: redis
      labels:
        app: redis
        role: master
    spec:
      ports:
      - port: 6379
        targetPort: 6379
      selector:
        app: redis
        role: master
  '';

  redisImage = pkgs.dockerTools.buildImage {
    name = "redis";
    tag = "latest";
    contents = pkgs.redis;
    config.Entrypoint = "/bin/redis-server";
  };

  testSimplePod = ''
    $kubernetes->execute("docker load < ${redisImage}");
    $kubernetes->waitUntilSucceeds("kubectl create -f ${redisPod}");
    $kubernetes->succeed("kubectl create -f ${redisService}");
    $kubernetes->waitUntilSucceeds("kubectl get pod redis | grep Running");
    $kubernetes->succeed("nc -z \$\(dig \@10.10.0.1 redis.default.svc.cluster.local +short\) 6379");
  '';
in {
  # This test runs kubernetes on a single node
  trivial = makeTest {
    name = "kubernetes-trivial";

    nodes = {
      kubernetes =
        { config, pkgs, lib, nodes, ... }:
          {
            virtualisation.memorySize = 768;
            virtualisation.diskSize = 2048;

            programs.bash.enableCompletion = true;

            services.kubernetes.roles = ["master" "node"];
            services.kubernetes.verbose = true;
            services.kubernetes.kubelet.clusterDns = "10.10.0.1";
            virtualisation.docker.extraOptions = "--iptables=false --ip-masq=false -b cbr0";

            networking.bridges.cbr0.interfaces = [];
            networking.interfaces = {
              cbr0 = {
                ipAddress = "10.10.0.1";
                prefixLength = 24;
              };
            };

            environment.systemPackages = [ pkgs.bind pkgs.tcpdump pkgs.utillinux ];
          };
    };

    testScript = ''
      startAll;

      $kubernetes->waitUntilSucceeds("kubectl get nodes | grep kubernetes | grep Ready");

      ${testSimplePod}
    '';
  };

  cluster = let
    runWithOpenSSL = file: cmd: pkgs.runCommand file {
      buildInputs = [ pkgs.openssl ];
    } cmd;

    ca_key = runWithOpenSSL "ca-key.pem" "openssl genrsa -out $out 2048";
    ca_pem = runWithOpenSSL "ca.pem" ''
      openssl req \
        -x509 -new -nodes -key ${ca_key} \
        -days 10000 -out $out -subj "/CN=etcd-ca"
    '';
    etcd_key = runWithOpenSSL "etcd-key.pem" "openssl genrsa -out $out 2048";
    etcd_csr = runWithOpenSSL "etcd.csr" ''
      openssl req \
        -new -key ${etcd_key} \
        -out $out -subj "/CN=etcd" \
        -config ${openssl_cnf}
    '';
    etcd_cert = runWithOpenSSL "etcd.pem" ''
      openssl x509 \
        -req -in ${etcd_csr} \
        -CA ${ca_pem} -CAkey ${ca_key} \
        -CAcreateserial -out $out \
        -days 365 -extensions v3_req \
        -extfile ${openssl_cnf}
    '';

    etcd_client_key = runWithOpenSSL "etcd-client-key.pem"
      "openssl genrsa -out $out 2048";

    etcd_client_csr = runWithOpenSSL "etcd-client-key.pem" ''
      openssl req \
        -new -key ${etcd_client_key} \
        -out $out -subj "/CN=etcd-client" \
        -config ${client_openssl_cnf}
    '';

    etcd_client_cert = runWithOpenSSL "etcd-client.crt" ''
      openssl x509 \
        -req -in ${etcd_client_csr} \
        -CA ${ca_pem} -CAkey ${ca_key} -CAcreateserial \
        -out $out -days 365 -extensions v3_req \
        -extfile ${client_openssl_cnf}
    '';

    openssl_cnf = pkgs.writeText "openssl.cnf" ''
      ions = v3_req
      distinguished_name = req_distinguished_name
      [req_distinguished_name]
      [ v3_req ]
      basicConstraints = CA:FALSE
      keyUsage = digitalSignature, keyEncipherment
      extendedKeyUsage = serverAuth
      subjectAltName = @alt_names
      [alt_names]
      DNS.1 = etcd1
      DNS.2 = etcd2
      DNS.3 = etcd3
      IP.1 = 127.0.0.1
    '';

    client_openssl_cnf = pkgs.writeText "client-openssl.cnf" ''
      ions = v3_req
      distinguished_name = req_distinguished_name
      [req_distinguished_name]
      [ v3_req ]
      basicConstraints = CA:FALSE
      keyUsage = digitalSignature, keyEncipherment
      extendedKeyUsage = clientAuth
    '';

    etcdNodeConfig = {
      services = {
        etcd = {
          enable = true;
          keyFile = etcd_key;
          certFile = etcd_cert;
          trustedCaFile = ca_pem;
          peerClientCertAuth = true;
          listenClientUrls = ["https://0.0.0.0:2379"];
          listenPeerUrls = ["https://0.0.0.0:2380"];
        };
      };

      environment.variables = {
        ETCDCTL_CERT_FILE = "${etcd_client_cert}";
        ETCDCTL_KEY_FILE = "${etcd_client_key}";
        ETCDCTL_CA_FILE = "${ca_pem}";
        ETCDCTL_PEERS = "https://127.0.0.1:2379";
      };

      networking.firewall.allowedTCPPorts = [ 2379 2380 ];
    };

    kubeConfig = {
      virtualisation.diskSize = 2048;
      programs.bash.enableCompletion = true;

      services.flannel = {
        enable = true;
        network = "10.10.0.0/16";
        iface = "eth1";
        etcd = {
          endpoints = ["https://etcd1:2379" "https://etcd2:2379" "https://etcd3:2379"];
          keyFile = etcd_client_key;
          certFile = etcd_client_cert;
          caFile = ca_pem;
        };
      };

      # vxlan
      networking.firewall.allowedUDPPorts = [ 8472 ];

      systemd.services.docker.after = ["flannel.service"];
      systemd.services.docker.serviceConfig.EnvironmentFile = "/run/flannel/subnet.env";
      virtualisation.docker.extraOptions = "--iptables=false --ip-masq=false --bip $FLANNEL_SUBNET";

      services.kubernetes.verbose = true;
      services.kubernetes.etcd = {
        servers = ["https://etcd1:2379" "https://etcd2:2379" "https://etcd3:2379"];
        keyFile = etcd_client_key;
        certFile = etcd_client_cert;
        caFile = ca_pem;
      };

      environment.systemPackages = [ pkgs.bind pkgs.tcpdump pkgs.utillinux ];
    };

    kubeMasterConfig = {pkgs, ...}: {
      services.kubernetes.roles = ["master"];
      services.kubernetes.scheduler.leaderElect = true;
      services.kubernetes.controllerManager.leaderElect = true;
    };

    kubeWorkerConfig = { pkgs, ... }: {
      services.kubernetes.roles = ["node"];
    };
  in makeTest {
    name = "kubernetes-cluster";

    nodes = {
      etcd1 = { config, pkgs, nodes, ... }: {
        require = [etcdNodeConfig];
        services.etcd = {
          advertiseClientUrls = ["https://etcd1:2379"];
          initialCluster = ["etcd1=https://etcd1:2380" "etcd2=https://etcd2:2380" "etcd3=https://etcd3:2380"];
          initialAdvertisePeerUrls = ["https://etcd1:2380"];
        };
      };

      etcd2 = { config, pkgs, ... }: {
        require = [etcdNodeConfig];
        services.etcd = {
          advertiseClientUrls = ["https://etcd2:2379"];
          initialCluster = ["etcd1=https://etcd1:2380" "etcd2=https://etcd2:2380" "etcd3=https://etcd3:2380"];
          initialAdvertisePeerUrls = ["https://etcd2:2380"];
        };
      };

      etcd3 = { config, pkgs, ... }: {
        require = [etcdNodeConfig];
        services.etcd = {
          advertiseClientUrls = ["https://etcd3:2379"];
          initialCluster = ["etcd1=https://etcd1:2380" "etcd2=https://etcd2:2380" "etcd3=https://etcd3:2380"];
          initialAdvertisePeerUrls = ["https://etcd3:2380"];
        };
      };

      kubeMaster1 = { config, pkgs, lib, nodes, ... }: {
        require = [kubeMasterConfig];
      };

      kubeMaster2 = { config, pkgs, lib, nodes, ... }: {
        require = [kubeMasterConfig];
      };

      kubeWorker1 = { config, pkgs, lib, nodes, ... }: {
        require = [kubeWorkerConfig];
      };

      kubeWorker2 = { config, pkgs, lib, nodes, ... }: {
        require = [kubeWorkerConfig];
      };
    };

    testScript = ''
      startAll;
    '';
  };
}
