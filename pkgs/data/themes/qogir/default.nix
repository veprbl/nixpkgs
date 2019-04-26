{ stdenv, fetchFromGitHub, gdk_pixbuf, librsvg, gtk-engine-murrine }:

stdenv.mkDerivation rec {
  pname = "qogir-theme";
  version = "2019-04-26";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = pname;
    rev = "aa0e2cf04435f6b8b6f3b731d111d999a3e525c9";
    sha256 = "1qm3acynz90dkga0mrdwinm8jz937i2zkfwzmw3ii0xm0mh6phf2";
  };

  buildInputs = [ gdk_pixbuf librsvg ];

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  installPhase = ''
    patchShebangs .
    mkdir -p $out/share/themes
    name= ./Install -d $out/share/themes
  '';

  meta = with stdenv.lib; {
    description = "A flat Design theme for GTK based desktop environments";
    homepage = https://vinceliuice.github.io/Qogir-theme;
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = [ maintainers.romildo ];
  };
}
