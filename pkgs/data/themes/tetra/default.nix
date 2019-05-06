{ stdenv, fetchFromGitHub, gtk3, sassc }:

stdenv.mkDerivation rec {
  pname = "tetra-gtk-theme";
  version = "201905-refresh";

  src = fetchFromGitHub {
    owner  = "hrdwrrsk";
    repo   = pname;
    rev    = version;
    #rev = "156815fd9d828928854f24f980ffe579cc59c8ab";
    sha256 = "1yzlzibm66127gqax8g2bnl0az4plwljcpasdry629xwsbnfycg2";
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
    description = "Adwaita-based gtk+ theme with design influence from elementary OS and Vertex gtk+ theme";
    homepage    = https://github.com/hrdwrrsk/tetra-gtk-theme;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ dtzWill ];
    platforms   = platforms.linux;
  };
}
