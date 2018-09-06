{ stdenv, fetchurl, fetchpatch, autoconf213, pkgconfig, perl, python2, zip, which, readline, icu, zlib, nspr }:

let
  version = "60.2.0";
in stdenv.mkDerivation rec {
  name = "spidermonkey-${version}";

  src = fetchurl {
    url = "mirror://mozilla/firefox/releases/${version}esr/source/firefox-${version}esr.source.tar.xz";
    sha256 = "05vpwyxsy7q6w6ff1r51wd69hzcl36rfkqr28gklq8s8as5xqnvr";
  };

  buildInputs = [ readline icu zlib nspr ];
  nativeBuildInputs = [ autoconf213 pkgconfig perl which python2 zip ];

  # Apparently this package fails to build correctly with modern compilers, which at least
  # on ARMv6 causes polkit testsuite to break with an assertion failure in spidermonkey.
  # These flags were stolen from:
  # https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/js52
  NIX_CFLAGS_COMPILE = "-fno-delete-null-pointer-checks -fno-strict-aliasing -fno-tree-vrp";

  patches = [
    (fetchpatch {
      url = https://bug1415202.bmoattachments.org/attachment.cgi?id=8926363;
      sha256 = "082ryrvqa3lvs67v3sq9kf2jshf4qp1fpi195wffc40jdrl8fnin";
    })
    (fetchpatch {
      url = https://salsa.debian.org/gnome-team/mozjs52/raw/debian/master/debian/patches/fix-soname.patch;
      sha256 = "0dd7z4z4v0sqvvxk2psvzfz5mbdac690jgb8rh8xn50pb35xgmfj";
    })
    # # needed to build gnome3.gjs
    # (fetchpatch {
    #   name = "mozjs52-disable-mozglue.patch";
    #   url = https://git.archlinux.org/svntogit/packages.git/plain/trunk/mozjs52-disable-mozglue.patch?h=packages/js52&id=4279d2e18d9a44f6375f584911f63d13de7704be;
    #   sha256 = "18wkss0agdyff107p5lfflk72qiz350xqw2yqc353alkx4fsfpz0";
    # })
  ];

  preConfigure = ''
    export CXXFLAGS="-fpermissive"
    export LIBXUL_DIST=$out
    export PYTHON="${python2.interpreter}"

    cd js/src

    autoconf
  '';

  configureFlags = [
    "--with-system-nspr"
    "--with-system-zlib"
    "--with-system-icu"
    "--with-intl-api"
    "--enable-readline"
    "--enable-shared-js"
    "--enable-release"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Mozilla's JavaScript engine written in C/C++";
    homepage = https://developer.mozilla.org/en/SpiderMonkey;
    license = licenses.gpl2; # TODO: MPL/GPL/LGPL tri-license.
    maintainers = [ maintainers.abbradar ];
    platforms = platforms.linux;
  };
}
