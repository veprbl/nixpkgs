{ config, pkgs, ... }:

with pkgs.lib;

let

  gcfg = config.services.bitcoin;
  libDir = "/var/lib/bitcoin";

  makeBitcoinWallet = cfg: name:
    let
      dataDir = "${libDir}/${name}";

      configFile = pkgs.writeText "${name}.conf"
        ''
          printtoconsole=1
          datadir=${dataDir}
          ${cfg.config}
        '';

    in {
      description = "Bitcoin instance ‘${name}’";

      wantedBy = [ "multi-user.target" ];
      after = [ "network-interfaces.target" ];

      preStart = "mkdir -p ${dataDir}";

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/${cfg.package.binName} -conf=${configFile}";
        User = gcfg.user;
        Restart = "always";
      };
    };

in {

  ###### interface

  options = {

    services.bitcoin = {

      user = mkOption {
        default = "bitcoin";
        description = "User account under which bitcoin related services run";
      };

      wallets = mkOption {
        default = {};

        example = literalExample ''
          {
            bitcoin = {
              config = '''
                rpcuser=test
                rpcpassword=dasdGfhoiu35BCV47586fgdh234GDFSEG
                rpcport=7333
              ''';
              package = pkgs.bitcoinWallets.bitcoin;
            };
            litecoin = {
              config = '''
                rpcuser=liteuserx
                rpcpassword=nkrt345udsdfjhgjhsdfuyrt78rtTJHRFHTDTYD
                rpcport=9334
                port=9335
                gen=0
              ''';
              package = pkgs.bitcoinWallets.litecoin;
            };
          }
        '';

        description = ''
          Each attribute of this option defines a systemd service that
          runs a bitcoin wallet instance. The name of each systemd service is
          <literal>bitcoin-<replaceable>name</replaceable>.service</literal>,
          where <replaceable>name</replaceable> is the corresponding
          attribute name.
        '';

        type = types.attrsOf types.optionSet;

        options = {
          config = mkOption {
            description = "Configuration of this bitcoin wallet instance.";
            default = ''
              rpcuser=bitcoin
              rpcpassword=test
            '';
            type = types.lines;
          };

          package = mkOption {
            description = "Which crypto currency package to use";
            default = pkgs.bitcoin;
          };
        };
      };

    };

  };


  ###### implementation

  config = mkIf (gcfg.wallets != {}) {

    users.extraUsers = optionalAttrs (gcfg.user == "bitcoin") (singleton
      { name = "bitcoin";
        uid = config.ids.uids.bitcoin;
        description = "Bitcoin user";
        home = libDir;
        createHome = true;
      });

    systemd.services = listToAttrs (mapAttrsFlatten (name: value: nameValuePair "${name}" (makeBitcoinWallet value name)) gcfg.wallets);

  };

}
