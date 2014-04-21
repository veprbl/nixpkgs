{ stdenv, fetchurl, pkgconfig, which, zlib, bzip2, libpng, gnumake
  # FreeType supports sub-pixel rendering.  This is patented by
  # Microsoft, so it is disabled by default.  This option allows it to
  # be enabled.  See http://www.freetype.org/patents.html.
, useEncumberedCode ? true
}:

let
  version = "2.5.3";

  fetch_bohoomil = name: sha256: fetchurl {
    url = https://raw.githubusercontent.com/bohoomil/fontconfig-ultimate/8a155db28f264520596cc3e76eb44824bdb30f8e/01_freetype2-iu/ + name;
    inherit sha256;
  };
in
with { inherit (stdenv.lib) optional optionalString; };
stdenv.mkDerivation rec {
  name = "freetype-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/freetype/${name}.tar.bz2";
    sha256 = "0pppcn73b5pwd7zdi9yfx16f5i93y18q7q4jmlkwmwrfsllqp160";
  };

  patches = [ ./enable-validation.patch ] # from Gentoo
    ++ [
      (fetch_bohoomil "freetype-2.5.3-pkgconfig.patch" "12z6l1vjix543s9n2hvscl4l1nwkg9gq61h1k0h3qr8v196srsxw")
      (fetch_bohoomil "fix_segfault_with_harfbuzz.diff" "033vcz0cr5k5zgrz7hdyc4v4q3pli952z95cghx8p75yvahbm9l4")
    ]
    ++ optional useEncumberedCode
      (fetch_bohoomil "infinality-2.5.3.patch" "1df0kcgrns19pi5qc60q1p639wrgwjx8cwc27z9fikf5nqz416c8")
    ;

  propagatedBuildInputs = [ zlib bzip2 libpng ]; # needed when linking against freetype
  # dependence on harfbuzz is looser than the reverse dependence
  buildInputs = [ pkgconfig which ]
    # FreeType requires GNU Make, which is not part of stdenv on FreeBSD.
    ++ optional (!stdenv.isLinux) gnumake;

  # from Gentoo, see https://bugzilla.redhat.com/show_bug.cgi?id=506840
  NIX_CFLAGS_COMPILE = "-fno-strict-aliasing";
  # The asm for armel is written with the 'asm' keyword.
  CFLAGS = optionalString stdenv.isArm "-std=gnu99";

  enableParallelBuilding = true;

  doCheck = true;

  postInstall = ''ln -s freetype2 "$out"/include/freetype''; # compat hack

  crossAttrs = {
    # Somehow it calls the unwrapped gcc, "i686-pc-linux-gnu-gcc", instead
    # of gcc. I think it's due to the unwrapped gcc being in the PATH. I don't
    # know why it's on the PATH.
    configureFlags = "--disable-static CC_BUILD=gcc";
  };

  meta = with stdenv.lib; {
    description = "A font rendering engine";
    homepage = http://www.freetype.org/;
    license = licenses.gpl2Plus; # or the FreeType License (BSD + advertising clause)
    #ToDo: encumbered = useEncumberedCode;
    platforms = platforms.all;
  };
}
