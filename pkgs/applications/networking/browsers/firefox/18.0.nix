{ stdenv, fetchurl, pkgconfig, gtk, pango, perl, python, zip, libIDL
, libjpeg, libpng, zlib, cairo, dbus, dbus_glib, bzip2, xlibs
, freetype, fontconfig, file, alsaLib, nspr, nss, libnotify
, yasm, mesa, sqlite, unzip, makeWrapper, pysqlite

, # If you want the resulting program to call itself "Firefox" instead
  # of "Shiretoko" or whatever, enable this option.  However, those
  # binaries may not be distributed without permission from the
  # Mozilla Foundation, see
  # http://www.mozilla.org/foundation/trademarks/.
  enableOfficialBranding ? false
}:

assert stdenv.gcc ? libc && stdenv.gcc.libc != null;

rec {

  firefoxVersion = "18.0.2";

  xulVersion = "18.0.2"; # this attribute is used by other packages


  src = fetchurl {
    urls = [
        # It is better to use this url for official releases, to take load off Mozilla's ftp server.
        "http://releases.mozilla.org/pub/mozilla.org/firefox/releases/${firefoxVersion}/source/firefox-${firefoxVersion}.source.tar.bz2"
        # Fall back to this url for versions not available at releases.mozilla.org.
        "ftp://ftp.mozilla.org/pub/mozilla.org/firefox/releases/${firefoxVersion}/source/firefox-${firefoxVersion}.source.tar.bz2"
    ];
    sha1 = "fe5810d61edf6f4dc8bc477a08f9483b955f747b";
  };

  commonConfigureFlags =
    [ "--enable-optimize"
      #"--enable-profiling"
      "--disable-debug"
      "--enable-strip"
      # "--with-system-jpeg" # Too old in nixpkgs
      "--with-system-zlib"
      "--with-system-bz2"
      "--with-system-nspr"
      # "--with-system-nss" # Too old in nixpkgs
      # "--with-system-png" # <-- "--with-system-png won't work because the system's libpng doesn't have APNG support"
      # "--enable-system-cairo" # disabled for the moment because our Cairo is too old
      "--enable-system-sqlite"
      "--disable-crashreporter"
      "--disable-tests"
      "--disable-necko-wifi" # maybe we want to enable this at some point
      "--disable-installer"
      "--disable-updater"
    ];


  xulrunner = stdenv.mkDerivation rec {
    name = "xulrunner-${xulVersion}";

    inherit src;

    buildInputs =
      [ pkgconfig gtk perl zip libIDL libjpeg libpng zlib cairo bzip2
        python dbus dbus_glib pango freetype fontconfig xlibs.libXi
        xlibs.libX11 xlibs.libXrender xlibs.libXft xlibs.libXt file
        alsaLib nspr nss libnotify xlibs.pixman yasm mesa
        xlibs.libXScrnSaver xlibs.scrnsaverproto pysqlite
        xlibs.libXext xlibs.xextproto sqlite unzip makeWrapper
      ];

    configureFlags =
      [ "--enable-application=xulrunner"
        "--disable-javaxpcom"
      ] ++ commonConfigureFlags;

    enableParallelBuilding = true;

    preConfigure =
      ''
        export NIX_LDFLAGS="$NIX_LDFLAGS -L$out/lib/xulrunner-${xulVersion}"

        mkdir ../objdir
        cd ../objdir
        configureScript=../mozilla-release/configure
      ''; # */

    #installFlags = "SKIP_GRE_REGISTRATION=1";

    postInstall = ''
      # Fix run-mozilla.sh search
      libDir=$(cd $out/lib && ls -d xulrunner-[0-9]*)
      echo libDir: $libDir
      test -n "$libDir"
      cd $out/bin
      rm xulrunner

      for i in $out/lib/$libDir/*; do
          file $i;
          if file $i | grep executable &>/dev/null; then
              echo -e '#! /bin/sh\nexec "'"$i"'" "$@"' > "$out/bin/$(basename "$i")";
              chmod a+x "$out/bin/$(basename "$i")";
          fi;
      done
      for i in $out/lib/$libDir/*.so; do
          patchelf --set-rpath "$(patchelf --print-rpath "$i"):$out/lib/$libDir" $i || true
      done
      for i in $out/lib/$libDir/{plugin-container,xulrunner,xulrunner-stub}; do
          wrapProgram $i --prefix LD_LIBRARY_PATH ':' "$out/lib/$libDir"
      done
      rm -f $out/bin/run-mozilla.sh
    ''; # */

    meta = {
      description = "Mozilla Firefox XUL runner";
      homepage = http://www.mozilla.com/en-US/firefox/;
    };

    passthru = { inherit gtk; version = xulVersion; };
  };


  firefox = stdenv.mkDerivation rec {
    name = "firefox-${firefoxVersion}";

    inherit src;

    enableParallelBuilding = true;

    buildInputs =
      [ pkgconfig gtk perl zip libIDL libjpeg zlib cairo bzip2 python
        dbus dbus_glib pango freetype fontconfig alsaLib nspr nss libnotify
        xlibs.pixman yasm mesa sqlite file unzip pysqlite
      ];

    propagatedBuildInputs = [xulrunner];

    configureFlags =
      [ "--enable-application=browser"
        "--with-libxul-sdk=${xulrunner}/lib/xulrunner-devel-${xulrunner.version}"
        "--enable-chrome-format=jar"
        "--disable-elf-hack"
      ]
      ++ commonConfigureFlags
      ++ stdenv.lib.optional enableOfficialBranding "--enable-official-branding";

    makeFlags = [
      "SYSTEM_LIBXUL=1"
    ];

    # Hack to work around make's idea of -lbz2 dependency
    preConfigure =
      ''
        find . -name Makefile.in -execdir sed -i '{}' -e '1ivpath %.so ${
          stdenv.lib.concatStringsSep ":"
            (map (s : s + "/lib") (buildInputs ++ [stdenv.gcc.libc]))
        }' ';'
      '';

    postInstall =
      ''
        ln -s ${xulrunner}/lib/xulrunner-${xulrunner.version} $(echo $out/lib/firefox-*)/xulrunner
        cd "$out/lib/"firefox-*
        rm firefox
        echo -e '#!${stdenv.shell}\nexec ${xulrunner}/bin/xulrunner "'"$PWD"'/application.ini" "$@"' > firefox
        chmod a+x firefox
      ''; # */

    meta = {
      description = "Mozilla Firefox - the browser, reloaded";
      homepage = http://www.mozilla.com/en-US/firefox/;
      maintainers = [ stdenv.lib.maintainers.eelco ];
    };

    passthru = {
      inherit gtk xulrunner nspr;
      isFirefox3Like = true;
    };
  };
}
