{ stdenv, fetchFromGitHub, gtk3, sassc }:

stdenv.mkDerivation rec {
  pname = "adementary-theme";
  version = "201905-refresh"; # plus commits for rename

  src = fetchFromGitHub {
    owner  = "hrdwrrsk";
    repo   = pname;
    #rev    = version;
    rev    = "6271e97038756ebfdfd8761e5b9fa1f43f39d037";
    sha256 = "0lb8bfjp6v9yixm89f20z5xrcwplkc9mfq07nyvivvbjkgppiqjc";
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
