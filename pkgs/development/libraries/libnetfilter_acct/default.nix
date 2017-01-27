{ stdenv, fetchurl, pkgconfig, libnfnetlink, libmnl }:

stdenv.mkDerivation rec {
  name = "libnetfilter_acct-${version}";
  version = "1.0.3";

  src = fetchurl {
    url = "http://netfilter.org/projects/libnetfilter_acct/files/${name}.tar.bz2";
    sha256 = "06lsjndgfjsgfjr43px2n2wk3nr7whz6r405mks3887y7vpwwl22";
  };

  buildInputs = [ libmnl ];
  propagatedBuildInputs = [ libnfnetlink ];
  nativeBuildInputs = [ pkgconfig ];

  meta = with stdenv.lib; {
    description = "Library providing interface to extended accounting infrastructure";
    homepage = http://netfilter.org/projects/libnetfilter_acct/;
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mic92 ];
  };
}
