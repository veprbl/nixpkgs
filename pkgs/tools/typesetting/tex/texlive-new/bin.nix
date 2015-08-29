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

  common = {
    year = "2015";
    src = fetchurl {
      url = ftp://tug.org/historic/systems/texlive/2015/texlive-20150521-source.tar.xz;
      sha256 = "ed9bcd7bdce899c3c27c16a8c5c3017c4f09e1d7fd097038351b72497e9d4669";
    };

    configureFlags = [
      "--with-banner-add=/NixOS.org"
      "--disable-missing" "--disable-native-texlive-build"
      "--enable-shared" # "--enable-cxx-runtime-hack" # static runtime
      "--enable-tex-synctex"
      "-C" # use configure cache to speed up
      # TODO: ghostscript questions?
      # https://www.tug.org/texlive/doc/tlbuild.html#Program_002dspecific-configure-options
    ]
      ++ map (libname: "--with-system-${libname}") [
      # see "from TL tree" vs. "Using installed"  in configure output
      "zziplib" "xpdf" "poppler" "mpfr" "gmp"
      "pixman" "potrace" "gd" "freetype2" "libpng" "libpaper" "zlib"
        # beware: xpdf means to use stuff from poppler :-/
    ];

    removeBundledLibs = ''
      rm -r libs/{cairo,freetype2,gd,gmp,graphite2,harfbuzz,icu,libpaper,libpng} \
        libs/{mpfr,pixman,poppler,potrace,xpdf,zlib,zziplib}
    '';
    preConfigure = common.removeBundledLibs + ''
      mkdir Work
      cd Work
    '' + lib.optionalString stdenv.isDarwin ''
      export DYLD_LIBRARY_PATH="${poppler}/lib"
    '';
    configureScript = "../configure";

    # clean broken links to stuff not built
    cleanBrokenLinks = ''
      for f in "$out"/bin/*; do
        if [[ ! -x "$f" ]]; then rm "$f"; fi
      done
    '';



    buildInputs = [
      pkgconfig
      /*teckit*/ zziplib poppler mpfr gmp
      pixman potrace gd freetype libpng libpaper zlib /*ptexenc kpathsea*/
      perl
    ];
  };
in rec { # un-indented

inherit (common) cleanBrokenLinks year;

dvisvgm = stdenv.mkDerivation {
  name = "texlive-dvisvgm.bin-${year}";

  inherit (common) src;

  buildInputs = [ pkgconfig core/*kpathsea*/ ghostscript zlib freetype potrace ];

  preConfigure = ''
    cd texk/dvisvgm
  '';

  configureFlags = common.configureFlags
    ++ [ "--with-system-libgs" "--with-system-kpathsea" ];

  enableParallelBuilding = true;
};

core = stdenv.mkDerivation {
  name = "texlive-bin-${year}";

  inherit (common) src buildInputs preConfigure configureScript;

  outputs = [ "out" "doc" ];

  configureFlags = common.configureFlags
    ++ [ "--without-x" ] # disable xdvik and xpdfopen
    ++ map (what: "--disable-${what}") [
      "dvisvgm" "dvipng" # ghostscript dependency
      "luatex" "luajittex" "mp" "pmp" "upmp" "mf" # cairo would bring in X and more
      "xetex" "bibtexu" "bibtex8" "bibtex-x" # ICU isn't small
    ]
    ++ [ "--without-system-harfbuzz" "--without-system-icu" ] # bogus configure

    ++ lib.optionals stdenv.isDarwin [
    # TODO: We should be able to fix these tests
    "--disable-devnag"
  ];

  ## doMainBuild
  /*
    sed -e 's@\<env ruby@${ruby}/bin/ruby@' -i $(grep 'env ruby' -rl . )
    sed -e 's@\<env perl@${perl}/bin/perl@' -i $(grep 'env perl' -rl . )
    sed -e 's@\<env python@${python}/bin/python@' -i $(grep 'env python' -rl . )
  */

  enableParallelBuilding = true;

  doCheck = false; # triptest fails, likely due to missing TEXMF tree
  preCheck = "patchShebangs ../texk/web2c";

  installTargets = [ "install" "texlinks" ];

  # TODO: perhaps improve texmf.cnf search locations
  postInstall = /* the perl modules are useful; take the rest from pkgs */ ''
    mv "$out/share/texmf-dist/web2c/texmf.cnf" .
    rm -r "$out/share/texmf-dist"
    mkdir -p "$out"/share/texmf-dist/{web2c,scripts/texlive/TeXLive}
    mv ./texmf.cnf "$out/share/texmf-dist/web2c/"
    cp ../texk/tests/TeXLive/*.pm "$out/share/texmf-dist/scripts/texlive/TeXLive/"
  '' + /* doc location identical with individual TeX pkgs */ ''
    mkdir -p "$doc/doc"
    mv "$out"/share/{man,info} "$doc"/doc
  '' + cleanBrokenLinks
    + stdenv.lib.optionalString stdenv.isDarwin ''
    for prog in $out/bin/*; do
      wrapProgram "$prog" --prefix DYLD_LIBRARY_PATH : "${poppler}/lib"
    done
  '';

  setupHook = ./setup-hook.sh; # TODO: maybe texmf-nix -> texmf (and all references)
  passthru = { inherit year; };

  meta = with stdenv.lib; {
    description = "Basic binaries for TeX Live";
    homepage    = http://www.tug.org/texlive;
    license     = stdenv.lib.licenses.gpl2;
    maintainers = with maintainers; [ vcunat lovek323 raskin jwiegley ];
    platforms   = platforms.all;
  };
};

} # un-indented

