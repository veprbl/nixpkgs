{ stdenv, fetchurl
, buildPackages
, pkgconfig, which, makeWrapper
, zlib, bzip2, libpng, gnumake, glib

, # FreeType supports LCD filtering (colloquially referred to as sub-pixel rendering).
  # LCD filtering is also known as ClearType and covered by several Microsoft patents.
  # This option allows it to be disabled. See http://www.freetype.org/patents.html.
  useEncumberedCode ? true
, xorg
}:

let
  inherit (stdenv.lib) optional optionalString;

  version = "2.10.0";

  demos_src = fetchurl {
    url = "mirror://savannah/freetype/ft2demos-${version}.tar.bz2";
    sha256 = "1fh6dmk6xn2jalcsg4ml5vvm5z5zn62pn6qzpnq4k4v0rp1gjrh4";
  };

in stdenv.mkDerivation rec {
  pname = "freetype";
  inherit version;

  meta = with stdenv.lib; {
    description = "A font rendering engine";
    longDescription = ''
      FreeType is a portable and efficient library for rendering fonts. It
      supports TrueType, Type 1, CFF fonts, and WOFF, PCF, FNT, BDF and PFR
      fonts. It has a bytecode interpreter and has an automatic hinter called
      autofit which can be used instead of hinting instructions included in
      fonts.
    '';
    homepage = https://www.freetype.org/;
    license = licenses.gpl2Plus; # or the FreeType License (BSD + advertising clause)
    platforms = platforms.all;
    maintainers = with maintainers; [ ttuegel ];
  };

  src = fetchurl {
    url = "mirror://savannah/${pname}/${pname}-${version}.tar.bz2";
    sha256 = "01mybx78n3n9dhzylbrdy42wxdwfn8rp514qdkzjy6b5ij965k7w";
  };

  postUnpack = ''
    unpackFile ${demos_src}
    mv ft2demos-* ft2demos
  '';

  propagatedBuildInputs = [ zlib bzip2 libpng ]; # needed when linking against freetype
  # dependence on harfbuzz is looser than the reverse dependence
  nativeBuildInputs = [ pkgconfig which makeWrapper ]
    # FreeType requires GNU Make, which is not part of stdenv on FreeBSD.
    ++ optional (!stdenv.isLinux) gnumake;

  patches =
    [ ./enable-table-validation.patch
    ] ++
    optional useEncumberedCode ./enable-subpixel-rendering.patch;

  outputs = [ "out" "dev" "demos" ];

  configureFlags = [ "--disable-static" "--bindir=$(dev)/bin" "--enable-freetype-config" ];

  postBuild = ''
    make -C ../ft2demos \
      TOP_DIR=$PWD \
      TOP_DIR_2=$PWD/../ft2demos \
      X11_PATH=${xorg.libX11}/include \
      exes
  '';

  buildInputs = [ xorg.libX11 ];

  # native compiler to generate building tool
  CC_BUILD = "${buildPackages.stdenv.cc}/bin/cc";

  # The asm for armel is written with the 'asm' keyword.
  CFLAGS = optionalString stdenv.isAarch32 "-std=gnu99";

  enableParallelBuilding = true;

  doCheck = true;

  postInstall = glib.flattenInclude + ''
    substituteInPlace $dev/bin/freetype-config \
      --replace ${buildPackages.pkgconfig} ${pkgconfig}

    wrapProgram "$dev/bin/freetype-config" \
      --set PKG_CONFIG_PATH "$PKG_CONFIG_PATH:$dev/lib/pkgconfig"
  '' + ''
    install -Dm755 -t $demos/bin ../ft2demos/bin/.libs/*
  '';
}
