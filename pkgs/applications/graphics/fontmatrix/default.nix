{ stdenv, fetchFromGitHub, cmake, qt4 }:

stdenv.mkDerivation rec {
  name = "fontmatrix-${version}";
  version = "2017-12-28";

  src = fetchFromGitHub {
    owner = "fontmatrix";
    repo = "fontmatrix";
#    rev = "v${version}";
    rev = "8108e6ea8b5944a92d7f27c40509b8e890ddaff1";
    sha256 = "05c7q7vrsi0ska84dirr650awking59917q08hysn3plpkr0r8ai";
  };

  buildInputs = [ qt4 ];

  nativeBuildInputs = [ cmake ];

  #hardeningDisable = [ "format" ];

  meta = with stdenv.lib; {
    description = "Fontmatrix is a free/libre font explorer for Linux, Windows and Mac";
    homepage = https://github.com/fontmatrix/fontmatrix;
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
