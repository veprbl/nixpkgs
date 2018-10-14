{ stdenv, fetchFromGitHub, fetchpatch, cmake, pkgconfig, scdoc, gnome3, gmime3, webkitgtk222x
, libsass, notmuch, boost, libsoup, wrapGAppsHook, glib-networking, protobuf, vim_configurable
, makeWrapper, python3Packages
, vim ? vim_configurable.override {
                    features = "normal";
                    gui = "auto";
                  }
}:

stdenv.mkDerivation rec {
  name = "astroid-${version}";
  version = "0.14";

  src = fetchFromGitHub {
    owner = "astroidmail";
    repo = "astroid";
    rev = "v${version}";
    sha256 = "1wkv1icsx3g3gq485dnvcdhr9srrjgz4ws1i1krcw9n61bj7gxh8";
  };

  nativeBuildInputs = [ cmake pkgconfig scdoc wrapGAppsHook ];

  buildInputs = [ gnome3.gtkmm gmime3 webkitgtk222x libsass gnome3.libpeas
                  python3Packages.python python3Packages.pygobject3 gnome3.vte
                  notmuch boost libsoup gnome3.gsettings-desktop-schemas gnome3.defaultIconTheme
                  glib-networking protobuf ] ++ (if (!stdenv.lib.isDerivation vim)  then [] else [ vim ]);

  patches = [
    (fetchpatch {
      url = "https://github.com/astroidmail/astroid/commit/c7364fe3560681c53e6aeac15a8710297cea3c05.patch";
      sha256 = "0dbfas0jgwcabshkyfr7n75nvahva2mqqm743x637r1p2v96vqwq";
    })
    (fetchpatch {
      url = "https://github.com/astroidmail/astroid/commit/cda29352783efb9be76e76a24ac6d2406697fe4b.patch";
      sha256 = "1wzqvkm6lzl4fpmqndl1z1afn8pi77zsglkpjypjhh5qsvq0jwvm";
    })
  ];

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
