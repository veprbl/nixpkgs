{ stdenv, lib, cmake, fetchFromGitHub }:

stdenv.mkDerivation rec {

  name = "catch-${version}";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "philsquared";
    repo = "Catch";
    rev = "v" + version;
    sha256 = "031a8jvwf6qj33jpnh4iyndlwizs6sgc3ayp96fpas2b8ddj53l3";
  };

  buildInputs = [ cmake ];
  dontUseCmakeConfigure = true;
  enableParallelBuilding = true;

  buildPhase = ''
    cmake -H. -BBuild -DCMAKE_BUILD_TYPE=Release -DUSE_CPP11=ON
    cd Build
    make
    cd ..
  '';

  installPhase = ''
    mkdir -p $out
    mv include $out/.
  '';

  meta = with stdenv.lib; {
    description = "A multi-paradigm automated test framework for C++ and Objective-C (and, maybe, C)";
    homepage = "http://catch-lib.net";
    license = licenses.boost;
    maintainers = with maintainers; [ edwtjo ];
    platforms = with platforms; unix;
  };
}
