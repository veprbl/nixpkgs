{ stdenv, fetchurl, pkgconfig, gnum4 }:
let
  ver_maj = "2.99"; # odd major numbers are unstable (esp 99 :P)
  ver_min = "12";
in
stdenv.mkDerivation rec {
  name = "libsigc++-${ver_maj}.${ver_min}";

  src = fetchurl {
    url = "mirror://gnome/sources/libsigc++/${ver_maj}/${name}.tar.xz";
    sha256 = "1a4hcry9y129gz3269rq5r3miwf27hay51jm09b2vbsvgwksw0nr";
  };

  nativeBuildInputs = [ pkgconfig gnum4 ];

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = https://libsigcplusplus.github.io/libsigcplusplus/;
    description = "A typesafe callback system for standard C++";
    license = licenses.lgpl21;
    platforms = platforms.all;
  };
}
