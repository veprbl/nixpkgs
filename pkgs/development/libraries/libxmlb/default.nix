{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, glib, libuuid, gobjectIntrospection, gtk-doc, shared-mime-info }:

stdenv.mkDerivation rec {
  name = "libxmlb-${version}";
  version = "0.1.4";

  outputs = [ "out" "lib" "dev" "devdoc" ];

  src = fetchFromGitHub {
    owner = "hughsie";
    repo = "libxmlb";
    rev = version;
    sha256 = "1dz2ragxbncsvwsbssvizgabhbvdczqwr6fdk71cpsrpzz93yn9j";
  };

  nativeBuildInputs = [ meson ninja pkgconfig gobjectIntrospection gtk-doc shared-mime-info ];

  buildInputs = [ glib libuuid ];

  mesonFlags = [
    "--libexecdir=${placeholder "out"}/libexec"
    "-Dgtkdoc=true"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A library to help create and query binary XML blobs";
    homepage = https://github.com/hughsie/libxmlb;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ jtojnar ];
    platforms = platforms.unix;
  };
}
