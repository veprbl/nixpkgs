# Basic test for neo4j

let
  neo4jpassword = "secret";
in import ./make-test.nix ({ pkgs, ...} : {
  name = "neo4j";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ dtzWill ];
  };

  nodes = {
    server = { config, lib, pkgs, ... }: {
      services.neo4j.enable = true;

      # XXX: These should be taken from service config, not hardcoded
      environment.variables = {
        NEO4J_HOME = "${pkgs.neo4j}/share/neo4j";
        NEO4J_CONF = "/var/lib/neo4j/conf";
      };
    };
  };


  testScript = ''
    startAll;

    $server->waitForUnit("neo4j");
    $server->waitForOpenPort("7474");

    # $server->succeed("neo4j-admin set-initial-password ${neo4jpassword}");

    # $server->succeed("NEO4J_HOME=/var/lib/neo4j cypher-shell -u neo4j -p ${neo4jpassword} --debug");
    # $server->succeed("neo4j console");
    $server->succeed("neo4j-shell");
  '';

})
