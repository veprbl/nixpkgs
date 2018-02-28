{ stdenv, fetchFromGitHub, gtk3, papirus-icon-theme }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "deepin-icon-theme";
  version = "15.12.52";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "0fgmii3qzdl9n9vh7zq54n75d200w6xw7gbgzdaxjxm3b10bjl38";
  };

  nativeBuildInputs = [ gtk3 papirus-icon-theme ];

  makeFlags = [ "PREFIX=$(out)" ];

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
