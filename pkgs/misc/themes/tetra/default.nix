{ stdenv, fetchFromGitHub, gtk3, sassc }:

stdenv.mkDerivation rec {
  name = "tetra-gtk-theme-${version}";
  version = "20190228";

  src = fetchFromGitHub {
    owner  = "hrdwrrsk";
    repo   = "tetra-gtk-theme";
    #rev    = version;
    rev = "ab4c699841053138f5d52e23f299e5a4219b79b0";
    sha256 = "0a2a8lq2sps0hzpqlc3zw6phkfxyfmpbmf4jjyg7w0bgv1s3v4mf";
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
