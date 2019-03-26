{ stdenv, fetchurl, lib
, autoconf, automake, gnum4, libtool, perl, gnulib, uthash, pkgconfig, gettext
, python, freetype, zlib, glib, libungif, libpng, libjpeg, libtiff, libxml2, cairo, pango
, withSpiro ? false, libspiro
, withGTK ? false, gtk2
, withPython ? true
, Carbon ? null, Cocoa ? null
}:

stdenv.mkDerivation rec {
  pname = "fontforge";
  version = "20190317";

  src = fetchurl {
    url = "https://github.com/${pname}/${pname}/releases/download/${version}/${pname}-${version}.tar.gz";
    sha256 = "1ddqbpc32cgbccdnv0lfw0qhj59hcqzb7616ph5lkvm91pnas4dp";
  };

  patches = [ ./fontforge-20140813-use-system-uthash.patch ];

  # do not use x87's 80-bit arithmetic, rouding errors result in very different font binaries
#  NIX_CFLAGS_COMPILE = lib.optionals stdenv.isi686 [ "-msse2" "-mfpmath=sse" ];

  nativeBuildInputs = [ pkgconfig autoconf automake gnum4 libtool perl gettext ];
  buildInputs = [
    uthash
    python freetype zlib glib libungif libpng libjpeg libtiff libxml2
  ]
    ++ lib.optionals withSpiro [libspiro]
    ++ lib.optionals withGTK [ gtk2 cairo pango ]
    ++ lib.optionals stdenv.isDarwin [ Carbon Cocoa ];

  configureFlags =
    lib.optionals (!withPython) [ "--disable-python-scripting" "--disable-python-extension" ]
    ++ lib.optional withGTK "--enable-gtk2-use"
    ++ lib.optional (!withGTK) "--without-x";

  preConfigure = ''
    export GIT="$(type -P true)"
    cp -r "${gnulib}" ./gnulib
    chmod +w -R ./gnulib
    ./bootstrap --skip-git --gnulib-srcdir=./gnulib --force
  '';

  doCheck = false; # tries to wget some fonts
  doInstallCheck = doCheck;

  postInstall =
    # get rid of the runtime dependency on python
    lib.optionalString (!withPython) ''
      rm -r "$out/share/fontforge/python"
    '';

  enableParallelBuilding = true;

  meta = {
    description = "A font editor";
    homepage = http://fontforge.github.io;
    platforms = stdenv.lib.platforms.all;
    license = stdenv.lib.licenses.bsd3;
  };
}
