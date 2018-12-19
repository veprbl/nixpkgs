{ stdenv, fetchFromGitHub, meson, ninja, gtk3 }:

stdenv.mkDerivation rec {
  name = "elementary-gtk-theme-${version}";
  version = "5.2.1";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "stylesheet";
    rev = version;
    sha256 = "03l8m87f7z25svxk0hhcqnn4qnnqvasr5qwzq3s87lx25gwjml29";
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
