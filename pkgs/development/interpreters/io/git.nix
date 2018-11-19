{ stdenv, fetchFromGitHub, cmake, zlib, sqlite, gmp, libffi, cairo,
  ncurses, freetype, libGLU_combined, libpng, libtiff, libjpeg, readline, libsndfile,
  libxml2, freeglut, libsamplerate, pcre, libevent, libedit, yajl,
  python3, openssl, glfw, pkgconfig, libpthreadstubs, libXdmcp, libmemcached
}:

stdenv.mkDerivation rec {
  name = "io-${version}";
  version = "2018.09.22";
  src = fetchFromGitHub {
    owner = "stevedekorte";
    repo = "io";
    rev = "67dbe416568215d544582ba8f7f6bb6ee8922f7a";
    sha256 = "10vagwfsf5prgdgicxb1nz8aavc4zclq3n6dizwlbps79xj0j3gb";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    zlib sqlite gmp libffi cairo ncurses freetype
    libGLU_combined libpng libtiff libjpeg readline libsndfile libxml2
    freeglut libsamplerate pcre libevent libedit yajl
    pkgconfig glfw openssl libpthreadstubs libXdmcp
    libmemcached python3
  ];

  # for gcc5; c11 inline semantics breaks the build
  NIX_CFLAGS_COMPILE = "-fgnu89-inline";

  meta = with stdenv.lib; {
    description = "Io programming language";
    homepage = http://iolanguage.org/;
    license = licenses.bsd3;

    maintainers = with maintainers; [
      raskin
      z77z
      vrthra
    ];
    platforms = [ "x86_64-linux" ];
  };
}
