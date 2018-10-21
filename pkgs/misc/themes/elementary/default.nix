{ stdenv, fetchFromGitHub, meson, ninja, gtk3 }:

stdenv.mkDerivation rec {
  name = "elementary-gtk-theme-${version}";
  version = "5.2.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "stylesheet";
    rev = version;
    sha256 = "0rfpqkbrrbaga8mdpr5s48f13w634dfyk4l44bmg8nxhvzcd88m4";
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
