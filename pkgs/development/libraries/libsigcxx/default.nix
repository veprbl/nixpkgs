{ stdenv, fetchurl, pkgconfig, gnum4 }:
let
  ver_maj = "2.10"; # odd major numbers are unstable
  ver_min = "1";
in
stdenv.mkDerivation rec {
  name = "libsigc++-${ver_maj}.${ver_min}";

  src = fetchurl {
    url = "mirror://gnome/sources/libsigc++/${ver_maj}/${name}.tar.xz";
    sha256 = "00v08km4wwzbh6vjxb21388wb9dm6g2xh14rgwabnv4c2wk5z8n9";
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
