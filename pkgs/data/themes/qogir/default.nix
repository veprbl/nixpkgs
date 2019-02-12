{ stdenv, fetchFromGitHub, gdk_pixbuf, librsvg, gtk-engine-murrine }:

stdenv.mkDerivation rec {
  pname = "qogir-theme";
  version = "2019-02-11";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = pname;
    #rev = version;
    rev = "587232cc18f6d7457dc9bee5f74e703f234e6658";
    sha256 = "0bg6lj4s8sbaix89fkisqh1bamh6jjmn9nbvzlcwdm47s61g7xzk";
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
