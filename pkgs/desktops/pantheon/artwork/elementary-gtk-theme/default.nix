{ stdenv, fetchFromGitHub, pantheon, meson, ninja }:

stdenv.mkDerivation rec {
  pname = "elementary-gtk-theme";
  version = "5.2.1";
  repoName = "stylesheet";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = repoName;
    rev = version;
    sha256 = "03l8m87f7z25svxk0hhcqnn4qnnqvasr5qwzq3s87lx25gwjml29";
  };

  passthru = {
    updateScript = pantheon.updateScript {
      repoName = repoName;
      attrPath = pname;
    };
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  meta = with stdenv.lib; {
    description = "GTK theme designed to be smooth, attractive, fast, and usable";
    homepage = https://github.com/elementary/stylesheet;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = pantheon.maintainers;
  };
}
