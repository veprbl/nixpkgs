{ stdenv, fetchgit, fetchpatch, autoreconfHook, pkgconfig, gnum4, gtk-doc, glib, libsigcxx }:

let
  ver_maj = "2.56";
  ver_min = "0";
in
stdenv.mkDerivation rec {
  name = "glibmm-${ver_maj}.${ver_min}-git";

  src = fetchgit {
    url = "https://gitlab.gnome.org/GNOME/glibmm.git";
    rev = "cd42ee39a942585a35c71818145dceecc061f15b";
    sha256 = "0rrhy4zmv03qvyhp56sqh5snb5chpzawr3pjhwbdm0svssf27a3b";
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ autoreconfHook pkgconfig gnum4 gtk-doc ];
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
