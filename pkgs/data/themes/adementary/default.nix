{ stdenv, fetchFromGitHub, gtk3, sassc }:

stdenv.mkDerivation rec {
  pname = "adementary-theme";
  version = "201905-refresh-git"; # plus commits for rename

  src = fetchFromGitHub {
    owner  = "hrdwrrsk";
    repo   = pname;
    #rev    = version;
    rev    = "d8de1a7247c42104f57f46b7760feb230c3a6de6";
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
