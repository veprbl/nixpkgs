{ stdenv, fetchFromGitHub, gtk3, sassc }:

stdenv.mkDerivation rec {
  name = "tetra-gtk-theme-${version}";
  version = "2018-11-21";

  src = fetchFromGitHub {
    owner  = "hrdwrrsk";
    repo   = "tetra-gtk-theme";
    rev    = "0943e741690bff2a5166a183d5504a8b578e9458";
    sha256 = "117ccqvxph65pm0wpcvlw27zq63zq1r4lchnsq6v2afdxfdwdyn5";
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
