{ stdenv, fetchFromGitHub, pantheon, meson, ninja }:

stdenv.mkDerivation rec {
  pname = "elementary-gtk-theme";
  version = "5.2.2";
  repoName = "stylesheet";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = repoName;
    rev = version;
    sha256 = "10b44dz7ndrckvq25pdxav59rzjcjbcpxb64z4nz62rfshvnrn8q";
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
