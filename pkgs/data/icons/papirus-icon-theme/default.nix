{ stdenv, fetchFromGitHub, gtk3 }:

stdenv.mkDerivation rec {
  name = "papirus-icon-theme-${version}";
  version = "20190326";

  src = fetchFromGitHub {
    owner = "PapirusDevelopmentTeam";
    repo = "papirus-icon-theme";
    #rev = version;
    rev = "d6b0b98c82e4dc14f23b95ee0d27555906de73c3";
    sha256 = "0lrfy0bj6nx4iqsrass14vx4s7q40jgrna74rbx1455f66wwjmrp";
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
