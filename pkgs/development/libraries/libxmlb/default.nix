{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, glib, libuuid, gobjectIntrospection, gtk-doc, shared-mime-info, python3, docbook_xsl, docbook_xml_dtd_43 }:

stdenv.mkDerivation rec {
  name = "libxmlb-${version}";
  version = "0.1.5";

  outputs = [ "out" "lib" "dev" "devdoc" ];

  src = fetchFromGitHub {
    owner = "hughsie";
    repo = "libxmlb";
    rev = version;
    sha256 = "037j9fwkzsy3765gl2grkrmbxrfs67wlai213qbgsa5xn6fb8y68";
  };

  nativeBuildInputs = [ meson ninja pkgconfig gobjectIntrospection gtk-doc shared-mime-info docbook_xsl docbook_xml_dtd_43 ];

  buildInputs = [ glib libuuid python3 ];

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
