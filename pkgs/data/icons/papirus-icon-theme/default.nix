{ stdenv, fetchFromGitHub, gtk3 }:

stdenv.mkDerivation rec {
  name = "papirus-icon-theme-${version}";
  version = "20190104"; # no hyphens, as tagged releases do

  src = fetchFromGitHub {
    owner = "PapirusDevelopmentTeam";
    repo = "papirus-icon-theme";
    rev = "0ae204b43638c1017e7c543ea50ad78a3d3f6091";
    sha256 = "15qzyyw9504rfpip5xk93b3agz2x0njmfy3k7958k9k75g9kfiig";
  };

  nativeBuildInputs = [ gtk3 ];

  installPhase = ''
     mkdir -p $out/share/icons
     mv {,e}Papirus* $out/share/icons
  '';

  postFixup = ''
    for theme in $out/share/icons/*; do
      gtk-update-icon-cache $theme
    done
  '';

  meta = with stdenv.lib; {
    description = "Papirus icon theme";
    homepage = https://github.com/PapirusDevelopmentTeam/papirus-icon-theme;
    license = licenses.lgpl3;
    platforms = platforms.all;
  };
}
