{ stdenv, fetchFromGitHub, cmake, pkgconfig, scdoc, gnome3, gmime3, webkitgtk222x
, libsass, notmuch, boost, libsoup, wrapGAppsHook, glib-networking, protobuf, vim_configurable
, makeWrapper, python3Packages
, vim ? vim_configurable.override {
                    features = "normal";
                    gui = "auto";
                  }
}:

stdenv.mkDerivation rec {
  name = "astroid-${version}";
  version = "2018-11-30";

  src = fetchFromGitHub {
    owner = "astroidmail";
    repo = "astroid";
    rev = "d2659d4fd3e8052f861de2ff41725949189e7a92";
    sha256 = "19a02gakghlvdj34ywz4fib85cykb2nca3sc4k1bb3bslzc2k7y8";
  };

  nativeBuildInputs = [ cmake pkgconfig scdoc wrapGAppsHook ];

  buildInputs = [ gnome3.gtkmm gmime3 webkitgtk libsass gnome3.libpeas
                  python3Packages.python python3Packages.pygobject3 gnome3.vte
                  notmuch boost libsoup gnome3.gsettings-desktop-schemas gnome3.defaultIconTheme
                  glib-networking protobuf ] ++ (if (!stdenv.lib.isDerivation vim)  then [] else [ vim ]);

  postPatch = ''
    sed -i "s~gvim ~${vim}/bin/vim -g ~g" src/config.cc
    sed -i "s~ -geom 10x10~~g" src/config.cc
  '';

#  postInstall = ''
#    wrapProgram "$out/bin/astroid" --set CHARSET=en_us.UTF-8
#  '';

  doCheck = false; # needs X, likely works w/Xvfb if needed

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = https://astroidmail.github.io/;
    description = "GTK+ frontend to the notmuch mail system";
    maintainers = with maintainers; [ bdimcheff SuprDewd ];
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
