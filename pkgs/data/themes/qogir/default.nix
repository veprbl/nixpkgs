{ stdenv, fetchFromGitHub, gdk_pixbuf, librsvg, gtk-engine-murrine }:

stdenv.mkDerivation rec {
  pname = "qogir-theme";
  version = "2019-01-05";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = pname;
    #rev = version;
    rev = "1332febe1a5a51fa809deee494a7143c48a56500";
    sha256 = "00ll4vjh2qhvmm0wl4xkw6bhg0791yc17ca6p21bxfrvwn7mwmb2";
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
