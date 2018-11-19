{ stdenv, fetchFromGitHub, cmake, zlib, sqlite, gmp, libffi, cairo,
  ncurses, freetype, libGLU_combined, libpng, libtiff, libjpeg, readline, libsndfile,
  libxml2, freeglut, libsamplerate, pcre, libevent, libedit, yajl,
  python3, openssl, glfw, pkgconfig, libpthreadstubs, libXdmcp, libmemcached
}:

stdenv.mkDerivation rec {
  name = "io-${version}";
  version = "2017.09.06";
  src = fetchFromGitHub {
    owner = "stevedekorte";
    repo = "io";
    rev = version;
    sha256 = "07rg1zrz6i6ghp11cm14w7bbaaa1s8sb0y5i7gr2sds0ijlpq223";
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

  preConfigure = ''
    # The Addon generation (AsyncRequest and a others checked) seems to have
    # trouble with building on Virtual machines. Disabling them until it
    # can be fully investigated.
    sed -ie \
          "s/add_subdirectory(addons)/#add_subdirectory(addons)/g" \
          CMakeLists.txt
  '';

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
