{ stdenv, lib, fetchurl
, config
, zlib, bzip2, ncurses, libpng, flex, bison, libX11, libICE, xproto
, freetype, t1lib, gd, libXaw, icu, ghostscript, ed, libXt, libXpm, libXmu, libXext
, xextproto, perl, libSM, ruby, expat, curl, libjpeg, python, fontconfig, pkgconfig
, poppler, libpaper, graphite2, lesstif, zziplib, harfbuzz, texinfo, potrace, gmp, mpfr
, xpdf, cairo, pixman, xorg
, makeWrapper
}:


let
  texmfVersion = "2014.20141024";
  texmfSrc = fetchurl {
    url = "mirror://debian/pool/main/t/texlive-base/texlive-base_${texmfVersion}.orig.tar.xz";
    sha256 = "1a6968myfi81s76n9p1qljgpwia9mi55pkkz1q6lbnwybf97akj1";
  };

  langTexmfVersion = "2014.20141024";
  langTexmfSrc = fetchurl {
    url = "mirror://debian/pool/main/t/texlive-lang/texlive-lang_${langTexmfVersion}.orig.tar.xz";
    sha256 = "1ydz5m1v40n34g1l31r3vqg74rbr01x2f80drhz4igh21fm7zzpa";
  };

  year = "2015";
in
stdenv.mkDerivation rec {
  name = "texlive-bin-${year}";

  src = assert config.allowTexliveBuilds or true; fetchurl {
    url = ftp://tug.org/historic/systems/texlive/2015/texlive-20150521-source.tar.xz;
    sha256 = "ed9bcd7bdce899c3c27c16a8c5c3017c4f09e1d7fd097038351b72497e9d4669";
  };

  buildInputs = with xorg; [
    pkgconfig
    harfbuzz icu /*teckit*/ graphite2 zziplib poppler mpfr gmp
    cairo pixman potrace gd freetype libpng libpaper zlib /*ptexenc kpathsea*/
    libXmu libXaw
    perl
  ];

  configureFlags = [
    "--with-banner-add=/NixOS.org"
    "--disable-missing" "--disable-native-texlive-build"
    "--enable-shared" # "--enable-cxx-runtime-hack" # static runtime
    "--enable-tex-synctex"

    "-C" # use configure cache to speed up
  ]
    ++ map (libname: "--with-system-${libname}") [
    # see "from TL tree" vs. "Using installed"  in configure output
    "harfbuzz" "icu" "graphite2" "zziplib" "xpdf" "poppler" "mpfr" "gmp"
    "cairo" "pixman" "potrace" "gd" "freetype2" "libpng" "libpaper" "zlib"
      # beware: xpdf means to use stuff from poppler :-/
  ]
    ++ lib.optionals stdenv.isDarwin [
    # TODO: We should be able to fix these tests
    "--disable-devnag"

    # jww (2014-06-02): The following fails with:
    # FAIL: tests/dvisvgm
    "--disable-dvisvgm"
  ];

  passthru = { inherit year /*texmfSrc langTexmfSrc*/; };

  setupHook = ./setup-hook.sh;

  enableParallelBuilding = true;

  ## doMainBuild
  preConfigure = ""
  /*
    + ''
    mkdir "$out"
    tar xf ${texmfSrc} -C $out --strip-components=1
    tar xf ${langTexmfSrc} -C $out --strip-components=1
    sed -e s@/usr/bin/@@g -i $(grep /usr/bin/ -rl . )

    sed -e 's@dehypht-x-2013-05-26@dehypht-x-2014-05-21@' -i $(grep 'dehypht-x' -rl $out )
    sed -e 's@dehyphn-x-2013-05-26@dehyphn-x-2014-05-21@' -i $(grep 'dehyphn-x' -rl $out )

    sed -e 's@\<env ruby@${ruby}/bin/ruby@' -i $(grep 'env ruby' -rl . )
    sed -e 's@\<env perl@${perl}/bin/perl@' -i $(grep 'env perl' -rl . )
    sed -e 's@\<env python@${python}/bin/python@' -i $(grep 'env python' -rl . )

    sed -e '/ubidi_open/i#include <unicode/urename.h>' -i $(find . -name configure)
    sed -e 's/-lttf/-lfreetype/' -i $(find . -name configure)

    # sed -e s@ncurses/curses.h@curses.h@g -i $(grep ncurses/curses.h -rl . )
    sed -e '1i\#include <string.h>\n\#include <stdlib.h>' -i $( find libs/teckit -name '*.cpp' -o -name '*.c' )

    #NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${icu}/include/layout";

    #./Build --prefix="$out" --datadir="$out/share" --mandir="$out/share/man" --infodir="$out/share/info" \
    #  ${stdenv.lib.concatStringsSep " " configureFlags}

  ''
  */
    + ''
    mkdir Work
    cd Work
  '' + lib.optionalString stdenv.isDarwin ''
    export DYLD_LIBRARY_PATH="${poppler}/lib"
  '';

  configureScript = "../configure";

  #doCheck = true;
  # ../../../texk/web2c/../../build-aux/test-driver: ../../../texk/web2c/tests/write18-quote-test.pl: /usr/bin/env: bad interpreter: No such file or directory

  installTargets = [ "install" "texlinks" ];

    #mv "$out"/share/texmf{-dist,}
    # perl patching taken from buildPerlPackage and simplified
  postInstall = ''
    mkdir "$out/share/texmf-dist/scripts/texlive/TeXLive/"
    cp ../texk/tests/TeXLive/*.pm "$out/share/texmf-dist/scripts/texlive/TeXLive/"

    patchShebangs "$out/share/texmf-dist/scripts"

    perlFlags="-I$out/share/texmf-dist/scripts/texlive"
    find "$out/share/texmf-dist/scripts/texlive/" -type f -executable | while read fn; do
      first=$(dd if="$fn" count=2 bs=1 2> /dev/null)
      if test "$first" = "#!"; then
        echo "patching $fn..."
        sed -e "s|^#\!\(.*/perl.*\)$|#\! \1$perlFlags|" -i "$fn"
      fi
    done
  '';

  ignore = ''
  '' + /*promoteLibexec*/ ''
    mkdir -p $out/libexec/
    mv $out/bin $out/libexec/$(uname -m)
    mkdir -p $out/bin
    for i in "$out/libexec/"* "$out/libexec/"*/* ; do
        test \( \! -d "$i" \) -a \( -x "$i" -o -L "$i" \) || continue

      if [ -x "$i" ]; then
          echo -ne "#! $SHELL\\nexec $i \"\$@\"" >$out/bin/$(basename $i)
                chmod a+x $out/bin/$(basename $i)
      else
          mv "$i" "$out/libexec"
          ln -s "$(readlink -f "$out/libexec/$(basename "$i")")" "$out/bin/$(basename "$i")";
          ln -sf "$(readlink -f "$out/libexec/$(basename "$i")")" "$out/libexec/$(uname -m)/$(basename "$i")";
          rm "$out/libexec/$(basename "$i")"
      fi;
    done
  ''

    + /*patchShebangsInterim*/ /* ''
    for p in "$out"/{bin,libexec,share/texmf-dist/scripts,texmf-dist/scripts}; do
      patchShebangs "$p"
    done
  ''
    + */ /*doPostInstall*/ ''
    cp -r "$out/"texmf* "$out/share/" || true
    rm -rf "$out"/texmf*
    [ -d $out/share/texmf-config ] || ln -s $out/share/texmf-dist $out/share/texmf-config
    ln -s "$out"/share/texmf* "$out"/
  ''
/*
    PATH=$PATH:$out/bin mktexlsr $out/share/texmf*

    HOME=. PATH=$PATH:$out/bin updmap-sys --syncwithtrees

    # Prebuild the format files, as it used to be done with TeXLive 2007.
    # Luatex currently fails this way:
    #
    #   This is a summary of all `failed' messages:
    #   `luatex -ini  -jobname=luatex -progname=luatex luatex.ini' failed
    #   `luatex -ini  -jobname=dviluatex -progname=dviluatex dviluatex.ini' failed
    #
    # I find it acceptable, hence the "|| true".
    echo "building format files..."
    mkdir -p "$out/share/texmf-var/web2c"
    ln -sf "$out"/out/share/texmf* "$out"/
    PATH="$PATH:$out/bin" fmtutil-sys --all || true

    PATH=$PATH:$out/bin mktexlsr $out/share/texmf*
  ''
*/
    + stdenv.lib.optionalString stdenv.isDarwin ''
    for prog in $out/bin/*; do
      wrapProgram "$prog" --prefix DYLD_LIBRARY_PATH : "${poppler}/lib"
    done
  '';

  meta = with stdenv.lib; {
    description = "A TeX distribution";
    homepage    = http://www.tug.org/texlive;
    license     = stdenv.lib.licenses.gpl2;
    maintainers = with maintainers; [ lovek323 raskin jwiegley ];
    platforms   = platforms.unix;
    hydraPlatforms = [];
  };
}

/* TODOs:
  - patch/inspect kpathsea

  - let fontconfig search TeX fonts?
  <dir>/usr/share/texmf-dist/fonts/opentype</dir>
  <dir>/usr/share/texmf-dist/fonts/truetype</dir>
  <dir>/usr/local/share/texmf/fonts/opentype</dir>
  <dir>/usr/local/share/texmf/fonts/truetype</dir>

*/

