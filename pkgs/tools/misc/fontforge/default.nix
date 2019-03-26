{ stdenv, fetchurl, fetchFromGitHub, lib
, autoconf, automake, gnum4, libtool, perl, gnulib, uthash, pkgconfig, gettext
, python, freetype, zlib, glib, libungif, libpng, libjpeg, libtiff, libxml2, cairo, pango
, withSpiro ? false, libspiro
, withGTK ? false, gtk2
, withPython ? true
, withExtras ? true
, Carbon ? null, Cocoa ? null
}:

stdenv.mkDerivation rec {
  pname = "fontforge";
  version = "20190326";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "e284c7ec69e4f9d2c8e6db32d964b49359d1d423";
    sha256 = "1kv43130b9xyfdvv84cm8k75v9kql9h0nmirzjkaa8zg9jwsf1sr";
  };

  patches = [ ./fontforge-20140813-use-system-uthash.patch ];

  # do not use x87's 80-bit arithmetic, rouding errors result in very different font binaries
  NIX_CFLAGS_COMPILE = lib.optionals stdenv.isi686 [ "-msse2" "-mfpmath=sse" ];

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
    ++ lib.optional (!withGTK) "--without-x"
    ++ lib.optional withExtras "--enable-fontforge-extras";

  # work-around: git isn't really used, but configuration fails without it
  preConfigure = ''
    # The way $version propagates to $version of .pe-scripts (https://github.com/dejavu-fonts/dejavu-fonts/blob/358190f/scripts/generate.pe#L19)
    export SOURCE_DATE_EPOCH=$(date -d ${version} +%s)

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
