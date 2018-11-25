{ stdenv, fetchurl, fetchFromGitHub, buildNativeModule, fetchNodeModules
, electron, nodejs-8_x }:

stdenv.mkDerivation rec {
  name = "eDEX-UI-bare-${version}";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "GitSquared";
    repo = "edex-ui";
    rev = "v${version}";
    sha256 = "0wc8kjyym677a3j10mgdya2i9nsiry2fan3bkzh6f4a6p477vbp6";
  };

  node_modules_root = fetchNodeModules {
    inherit src;
    nodejs = nodejs-8_x;
    sha256 = "17l5zxhlfldh5bkfmzr5y0ljcbnx16cvv2zy77nb51jxd7x3485k";
  };

  node_modules_src = fetchNodeModules {
    src = "${src}/src";
    nodejs = nodejs-8_x;
    sha256 = "18ngij9m8mnsqanbd8kwg30ik76yh04z0243393jzk5jrs0j2dzk";
  };

  node_pty = buildNativeModule {
    name = "node-pty";
    nodejs = nodejs-8_x;
    headerVersion = electron.version;
    src = "${node_modules_src}/node-pty";
    sha256 = "100hpblcqgrk7hgvdlfg10rly9d357yfld1abizix0qi3db7zqw7";
    nodeSHA256 = "02wja8cd17ac2rcm9fbvim9v1xbz987j7kjfsh1dm47djjsv8j9z";
    headerSHA256 = "0qmqi9sq0zpqdqz63vjc3aw190fih4dhq7qsfkd3f8f9jww450yz";
  };

  configurePhase = ''
    cp -r --no-preserve=all $node_modules_root node_modules
    cp -r --no-preserve=all $node_modules_src src/node_modules
  '';

  buildPhase = ''
    rm -rf src/node_modules/node-pty
    cp -r $node_pty src/node_modules/node-pty
  '';

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';

  meta = with stdenv.lib; {
    description = "A fullscreen desktop application resembling a sci-fi computer interface.";
    longDescription = ''
      eDEX-UI is a fullscreen desktop application resembling a sci-fi computer interface,
      heavily inspired from DEX-UI and the TRON Legacy movie effects. It runs the shell of
      your choice in a real terminal, and displays live information about your system. It was
      made to be used on large touchscreens but will work nicely on a regular desktop computer
      or perhaps a tablet PC or one of those funky 360° laptops with touchscreens.
    '';
    homepage = "https://github.com/GitSquared/edex-ui";
    license = licenses.gpl3;
    maintainers = with maintainers; [
      eadwu
    ];
    platforms = platforms.linux;
  };
}
