{ stdenv, fetchurl, fetchpatch, bison, flex, pkgconfig
, libnetfilter_conntrack, libnftnl, libmnl, libpcap }:

stdenv.mkDerivation rec {
  name = "iptables-${version}";
  version = "1.8.2";

  src = fetchurl {
    url = "https://www.netfilter.org/projects/iptables/files/${name}.tar.bz2";
    sha256 = "1bqj9hf3szy9r0w14iy23w00ir8448nfhpcprbwmcchsxm88nxx3";
  };

  nativeBuildInputs = [ bison flex pkgconfig ];

  buildInputs = [ libnetfilter_conntrack libnftnl libmnl libpcap ];

  # upstream patch
  patches = [ ./fix-format-security.patch ./fix-headers-collision.patch ];

  configureFlags = [
    "--enable-devel"
    "--enable-shared"
    "--enable-bpf-compiler"
  ];

  outputs = [ "out" "dev" ];

  meta = with stdenv.lib; {
    description = "A program to configure the Linux IP packet filtering ruleset";
    homepage = https://www.netfilter.org/projects/iptables/index.html;
    platforms = platforms.linux;
    maintainers = with maintainers; [ fpletz ];
    license = licenses.gpl2;
    downloadPage = "https://www.netfilter.org/projects/iptables/files/";
    updateWalker = true;
    inherit version;
  };
}
