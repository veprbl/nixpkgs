{ stdenv, fetchurl, openssl, zlib, libjpeg, xorg, coreutils }:

stdenv.mkDerivation rec {
  name = "x11vnc-0.9.13";

  src = fetchurl {
    url = "mirror://sourceforge/libvncserver/${name}.tar.gz";
    sha256 = "0fzib5xb1vbs8kdprr4z94v0fshj2c5hhaz69llaarwnc8p9z0pn";
  };

  buildInputs =
    [ libjpeg
      openssl
      xorg.libX11
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXinerama
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      xorg.xorgproto
      zlib
    ];

  preConfigure = ''
    configureFlags="--mandir=$out/share/man"

    substituteInPlace x11vnc/unixpw.c \
        --replace '"/bin/su"' '"/run/wrappers/bin/su"' \
        --replace '"/bin/true"' '"${coreutils}/bin/true"'

    sed -i -e '/#!\/bin\/sh/a"PATH=${xorg.xdpyinfo}\/bin:${xorg.xauth}\/bin:$PATH\\n"' -e 's|/bin/su|/run/wrappers/bin/su|g' x11vnc/ssltools.h
  '';

  meta = with stdenv.lib; {
    description = "A VNC server connected to a real X11 screen";
    homepage = http://www.karlrunge.com/x11vnc/;
    platforms = platforms.linux;
    license = licenses.gpl2;
  };
}
