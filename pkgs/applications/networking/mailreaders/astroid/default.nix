{ stdenv, fetchFromGitHub, cmake, pkgconfig, gnome3, gmime3, webkitgtk
, libsass, notmuch, boost, wrapGAppsHook, glib-networking, protobuf, vim_configurable
, gtkmm3, libpeas, gsettings-desktop-schemas
, makeWrapper, python3, python3Packages
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

  buildInputs = [
    gtkmm3 gmime3 webkitgtk libsass libpeas
    python3 python3Packages.pygobject3
    notmuch boost gsettings-desktop-schemas gnome3.adwaita-icon-theme
    glib-networking protobuf
  ]
  ++ (if (!stdenv.lib.isDerivation vim)  then [] else [ vim ]);
  #++ (if vim == null then [] else [ vim ]);

  postPatch = ''
    sed -i "s~gvim ~${vim}/bin/vim -g ~g" src/config.cc
    sed -i "s~ -geom 10x10~~g" src/config.cc
  '';

  postInstall = ''
    wrapProgram "$out/bin/astroid" \
      --set CHARSET en_us.UTF-8 \
      --prefix PYTHONPATH : "$PYTHONPATH"
  '';

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
