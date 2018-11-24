{ stdenv, fetchFromGitHub, gtk3, sassc }:

stdenv.mkDerivation rec {
  name = "tetra-gtk-theme-${version}";
  version = "2018-11-25";

  src = fetchFromGitHub {
    owner  = "hrdwrrsk";
    repo   = "tetra-gtk-theme";
    rev    = "e8ed095acbdfe5e7c7e253c2015f1f728d8e9739";
    sha256 = "04i146cl3wzl51wc8qvpzngg0y3m110392f4d6kx6hw9521rgkhi";
  };

  preBuild = ''
    # Shut up inkscape's warnings
    export HOME="$NIX_BUILD_ROOT"
  '';

  nativeBuildInputs = [ sassc ];
  buildInputs = [ gtk3 ];

  postPatch = "patchShebangs .";

  installPhase = ''
    mkdir -p $out/share/themes
    ./install.sh -d $out/share/themes
  '';

  meta = with stdenv.lib; {
    description = "Adwaita-based gtk+ theme with design influence from elementary OS and Vertex gtk+ theme.";
    homepage    = https://github.com/hrdwrrsk/tetra-gtk-theme;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ dtzWill ];
    platforms   = platforms.linux;
  };
}
