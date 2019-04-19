{ stdenv, fetchFromGitHub, pantheon, meson, ninja }:

stdenv.mkDerivation rec {
  pname = "elementary-gtk-theme";
  version = "5.2.3";
  repoName = "stylesheet";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = repoName;
    rev = version;
    sha256 = "1ghb6zl9yszsrxdkg8va1b29kyazbny2kncr9fdw6v2rbjnp7zhr";
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
