{ stdenv, fetchurl, fetchpatch, pkgconfig, gnum4, glib, libsigcxx }:

let
  ver_maj = "2.59";
  ver_min = "1";
in
stdenv.mkDerivation rec {
  name = "glibmm-${ver_maj}.${ver_min}";

  src = fetchurl {
    url = "mirror://gnome/sources/glibmm/${ver_maj}/${name}.tar.xz";
    sha256 = "1f36sr8hj1zqwn1alkyw05p8rwvwh5gc6fwv96z62gwc30wh3ilv";
  };

  outputs = [ "out" "dev" ];

  patches = [
    ./ustring-wchar.patch
    ./socketclient.patch
  ];

  nativeBuildInputs = [ pkgconfig gnum4 ];
  propagatedBuildInputs = [ glib libsigcxx ];

  enableParallelBuilding = true;

  doCheck = false; # fails. one test needs the net, another /etc/fstab

  meta = with stdenv.lib; {
    description = "C++ interface to the GLib library";

    homepage = https://gtkmm.org/;

    license = licenses.lgpl2Plus;

    maintainers = with maintainers; [raskin];
    platforms = platforms.unix;
  };
}
