{ stdenv, fetchFromGitHub, meson, ninja, gtk3 }:

stdenv.mkDerivation rec {
  name = "elementary-gtk-theme-${version}";
  #version = "5.2.1";
  version = "5.2.1.0.1"; # not really, date: "2018-12-28";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "stylesheet";
    #rev = version;
    rev = "a09e9f1f6fcc3cf85179b74cc725ba613cc2b95b";
    sha256 = "0lcan0i7g0s14492fsb4amh8zr9rdqf01va4vq15nwsxm03j0117";
  };

  nativeBuildInputs = [ meson ninja ];
  buildInputs = [ gtk3 ];

  meta = with stdenv.lib; {
    description = "GTK theme designed to be smooth, attractive, fast, and usable";
    homepage = https://github.com/elementary/stylesheet;
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ davidak ];
  };
}
