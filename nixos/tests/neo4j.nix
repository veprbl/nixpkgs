# Basic test for neo4j

import ./make-test.nix ({ pkgs, ...} : {
  name = "neo4j";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ dtzWill ];
  };

  nodes = {
    server = { config, lib, pkgs, ... }: {
      services.neo4j.enable = true;
    };
  };


  testScript = ''
    startAll;

    $server->waitForUnit("neo4j");
  '';

})
