{ stdenv, fetchurl, qmake, pkgconfig
, qtwebkit, qtx11extras
, accounts-qt, libnotify, libproxy }: # , signond }:

stdenv.mkDerivation rec {
  pname = "signon-ui";
  version = "0.15";

  src = fetchurl {
    url = "https://launchpad.net/signon-ui/trunk/${version}/+download/signon-ui-${version}.tar.bz2";
    sha256 = "1wsafsaxjmb2xdyivdwbdrmc8h2y5px3js4xdr3k77hjmy10lkx1";
  };

  nativeBuildInputs = [ qmake pkgconfig ];
  buildInputs = [ qtwebkit qtx11extras accounts-qt libnotify libproxy ];
}
