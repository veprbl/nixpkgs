{ stdenv, fetchurl, fetchFromGitLab, autoreconfHook, gtk-doc, which, pkgconfig, intltool, glib, gnome3, gtk3, gnupg, gpgme, dbus-glib, gcr }:

stdenv.mkDerivation rec {
  pname = "libcryptui";
  version = "3.12.2";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = pname;
    rev = "1c664b3d6f8d7985cec38c93d2b6a6334c2fbe49";
    sha256 = "0nsh64wj3mdgl4i4z7ma56n97ns6pibszkfgpwfn8c0a2i1gpibq";
  };
  #src = fetchurl {
  #  url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
  #  sha256 = "0rh8wa5k2iwbwppyvij2jdxmnlfjbna7kbh2a5n7zw4nnjkx3ski";
  #};

  autoreconfPhase = "./autogen.sh";

  nativeBuildInputs = [ autoreconfHook pkgconfig intltool gtk-doc which gnome3.gnome-common ];
  buildInputs = [ glib gtk3 gnupg gpgme dbus-glib gcr ];
  propagatedBuildInputs = [ dbus-glib ];

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
    };
  };

  meta = with stdenv.lib; {
    description = "Interface components for OpenPGP";
    homepage = https://gitlab.gnome.org/GNOME/libcryptui;
    license = licenses.lgpl21Plus;
    platforms = platforms.unix;
  };
}
