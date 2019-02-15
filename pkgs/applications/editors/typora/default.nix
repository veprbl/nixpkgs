{ stdenv, fetchurl, makeWrapper, wrapGAppsHook, dpkg
, electron_3, xdg_utils, gtk3, glib, gnome3, }:

stdenv.mkDerivation rec {
  pname = "typora";
  version = "0.9.64";

  src = fetchurl {
    url = "https://www.typora.io/linux/typora_${version}_amd64.deb";
    sha256 = "0dffydc11ys2i38gdy8080ph1xlbbzhcdcc06hyfv0dr0nf58a09";
  };

  nativeBuildInputs = [ dpkg makeWrapper wrapGAppsHook ];

  buildInputs = [ gtk3 glib gnome3.gsettings-desktop-schemas ];

  unpackPhase = "dpkg-deb -x $src .";

  #dontWrapGApps = true;

  installPhase = ''
    mkdir -p $out/bin $out/share/typora
    {
      cd usr
      mv share/typora/resources/app/* $out/share/typora
      mv share/applications $out/share
      mv share/icons $out/share
      mv share/doc $out/share
    }

    cat > $out/bin/typora <<EOF
      #!${electron_3}/bin/electron

      const { join } = require('path');
      const { app } = require('electron');

      const APP_DIR = '${placeholder "out"}/share/typora/';

      const conf = require(APP_DIR + 'package.json');

      app.setName(conf.name);
      app.setPath('userData', join(app.getPath('appData'), conf.name));
      app.getVersion = () => conf.version;

      process.argv.shift();
      require(APP_DIR + conf.main);
    EOF
    chmod +x $out/bin/typora
  '';

  meta = with stdenv.lib; {
    description = "A minimal Markdown reading & writing app";
    homepage = https://typora.io;
    license = licenses.unfree;
    maintainers = with maintainers; [ jensbin ];
    inherit (electron_3.meta) platforms;
  };
}
