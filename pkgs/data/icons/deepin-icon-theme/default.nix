{ stdenv, fetchFromGitHub, gtk3, papirus-icon-theme }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "deepin-icon-theme";
  version = "2018-02-23";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "19cbaa5c4929876cebe2162838e23246869d0fca";
    sha256 = "0lwca5nav4rfkd76fr5pcb17q2cr7cz2z42wybqsl73iwszn4h6v";
  };

  nativeBuildInputs = [ gtk3 ];
  propagatedUserEnvPkgs = [ papirus-icon-theme ];

  postPatch = ''
    substituteInPlace Makefile --replace "install-cursors hicolor-links" "install-cursors"
  '';

  makeFlags = [ "PREFIX:=$(out)" ];

  postFixup = ''
    for theme in $out/share/icons/*; do
      gtk-update-icon-cache $theme
    done
  '';

  meta = with stdenv.lib; {
    description = "Deepin icon theme";
    homepage = https://github.com/linuxdeepin/deepin-icon-theme;
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = with maintainers; [ romildo ];
  };
}
