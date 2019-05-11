{ stdenv, fetchFromGitHub, libX11, imlib2, hicolor-icon-theme }:

stdenv.mkDerivation rec {
  pname = "xlunch";
  version = "4.4.2";
  src = fetchFromGitHub {
    owner = "Tomas-M";
    repo = pname;
    rev = "v${version}";
    sha256 = "1frlmrlp6ff0ssv4ry9kqfzn49n424d83xgbkz62j014sxpqm7f2";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace /usr/ / \
      --replace "bash extra/genentries" "# bash extra/genentries"
  '';

  buildInputs = [ libX11 imlib2 hicolor-icon-theme ];

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  meta = with stdenv.lib; {
    description = "Graphical app launcher for X";
    homepage = http://xlunch.org;
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
