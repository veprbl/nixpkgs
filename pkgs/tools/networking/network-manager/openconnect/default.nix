{ stdenv, fetchurl, substituteAll, openconnect, intltool, pkgconfig, networkmanager, gcr, libsecret
, gtk3, withGnome ? true, gnome3, kmod }:

let
  pname   = "NetworkManager-openconnect";
  version = "1.2.4";
in stdenv.mkDerivation rec {
  name    = "${pname}${if withGnome then "-gnome" else ""}-${version}";

  src = fetchurl {
    url    = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "15j98wwspv6mcmy91w30as5qc1bzsnhlk060xhjy4qrvd37y0xx1";
  };

  patches = [
    (substituteAll {
      src = ./fix-paths.patch;
      inherit kmod openconnect;
    })
    ./can-persist.patch
    ./0001-Bug-770880-Revamp-certificate-warning-accept-dialog.patch
    ./0001-Bug-770880-Disallow-manual-cert-acceptance.patch
  ];

  buildInputs = [ openconnect networkmanager ]
    ++ stdenv.lib.optionals withGnome [ gtk3 gcr libsecret ];

  nativeBuildInputs = [ autoreconfHook /* autoreconf b/c patch configure.ac */ intltool pkgconfig ];

  configureFlags = [
    "--with-gnome=${if withGnome then "yes" else "no"}"
    "--enable-absolute-paths"
    "--without-libnm-glib"
  ];

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "networkmanager-openconnect";
    };
  };

  meta = with stdenv.lib; {
    description = "NetworkManager's OpenConnect plugin";
    inherit (networkmanager.meta) maintainers platforms;
    license = licenses.gpl2Plus;
  };
}
