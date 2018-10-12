{ stdenv, fetchFromGitHub, pkgconfig, glib, zlib, gnupg, gpgme, libidn2, gobjectIntrospection, libtool, autoconf, automake, which, gtk_doc, libunistring }:

stdenv.mkDerivation rec {
  version = "3.2.0-git";
  name = "gmime-${version}";

  src = fetchFromGitHub {
    owner = "jstedfast";
    repo = "gmime";
    rev = "da168513c91f9ed25d2e22c5b6a23fa50266a3bc";
    sha256 = "11qn02pddfclvy5376061jjlv0nbzm58imjfvgw9cawyr5mhp1iv";
  };

  outputs = [ "out" "dev" ];

  buildInputs = [ gobjectIntrospection zlib gpgme libidn2 libunistring ];
  nativeBuildInputs = [ pkgconfig libtool autoconf automake which gtk_doc ];
  propagatedBuildInputs = [ glib ];
  configureFlags = [ "--enable-introspection=yes" ];

  preConfigure = ''
    NOCONFIGURE=1 ./autogen.sh
  '';

  postPatch = ''
    substituteInPlace tests/testsuite.c \
      --replace /bin/rm rm
  '';

  checkInputs = [ gnupg ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = https://github.com/jstedfast/gmime/;
    description = "A C/C++ library for creating, editing and parsing MIME messages and structures";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ chaoflow ];
    platforms = platforms.unix;
  };
}
