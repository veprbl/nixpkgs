{ stdenv, fetchurl, meson, ninja, pkgconfig, exiv2, glib, gnome3, vala, gobjectIntrospection }:

let
  majorVersion = "0.10";
in
stdenv.mkDerivation rec {
  name = "gexiv2-${version}";
  version = "${majorVersion}.7";

  src = fetchurl {
    url = "mirror://gnome/sources/gexiv2/${majorVersion}/${name}.tar.xz";
    sha256 = "1f7312zygw77ml37i5qilhfvmjm59dn753ax71rcb2jm1p76vgcb";
  };

  patches = [
    # https://bugzilla.gnome.org/show_bug.cgi?id=791941
    (fetchurl {
      url = https://bugzilla.gnome.org/attachment.cgi?id=365969;
      sha256 = "06w744acgnz3hym7sm8c245yzlg05ldkmwgiz3yz4pp6h72brizj";
    })
    # https://bugzilla.gnome.org/show_bug.cgi?id=792431
    # https://github.com/NixOS/nixpkgs/issues/34512
    (fetchurl {
      url = https://github.com/GNOME/gexiv2/commit/d4b55f20ba6b90b56cb84fd5272f59b4853b8bac.patch;
      sha256 = "038xlq7czcp0kkrnyg1i6n7xawhda2518sk61vfl4s9z7c03nan3";
    })
  ];

  preConfigure = ''
    patchShebangs .
  '';

  nativeBuildInputs = [ meson ninja pkgconfig vala gobjectIntrospection ];
  buildInputs = [ glib ];
  propagatedBuildInputs = [ exiv2 ];

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Projects/gexiv2;
    description = "GObject wrapper around the Exiv2 photo metadata library";
    platforms = platforms.unix;
    maintainers = gnome3.maintainers;
  };
}
