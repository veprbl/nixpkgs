{ stdenv, fetchurl, pkgconfig, autoconf, automake, libtool, gtk_doc
, libgtop, gtk2, libgnome_keyring, intltool, GConf, startupnotification
}:

stdenv.mkDerivation rec {
  name = "libgksu-${version}";
  version = "2.0.12";

  src = fetchurl {
    url = "http://people.debian.org/~kov/gksu/${name}.tar.gz";
    md5 = "c7154c8806f791c10e7626ff123049d3";
  };

  buildInputs = [
    pkgconfig autoconf automake libtool
    libgtop gtk2 libgnome_keyring intltool GConf startupnotification
  ];

  patchPhase = ''
    patch -Np1 -i ${./libgksu-2.0.0-fbsd.patch}
    patch -Np1 -i ${./libgksu-2.0.7-libs.patch}
    patch -Np1 -i ${./libgksu-2.0.7-polinguas.patch}
    patch -Np0 -i ${./libgksu-2.0.12-fix-make-3.82.patch}
    patch -Np1 -i ${./libgksu-2.0.12-automake-1.11.2.patch}
  '';

  preConfigure = ''
    touch NEWS README
    intltoolize --force --copy --automake
    autoreconf -fi
  '';

  preBuild = ''
    export PATH=$PATH:${gtk_doc}/bin
  '';
}
