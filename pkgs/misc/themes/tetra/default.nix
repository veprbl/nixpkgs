{ stdenv, fetchFromGitHub, gtk3, sassc }:

stdenv.mkDerivation rec {
  name = "tetra-gtk-theme-${version}";
  version = "2018-12-14";

  src = fetchFromGitHub {
    owner  = "hrdwrrsk";
    repo   = "tetra-gtk-theme";
    rev    = "694679b4b4aee5fc07eb8aa9d41ee0004a872ac2";
    sha256 = "176qkp8la81jwxh5qc75v1d2s6ys1szyy3r8flxaikv3pg4s173n";
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
