{ fetchurl, fetchgit, stdenv, lib, flex, bison, db, iptables, pkgconfig }:

stdenv.mkDerivation rec {
  name = "iproute2-${version}";
  version = "4.14.99";

  src = fetchgit {
    url = "git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git";
    rev = "9bed02a5d576f2d3cb3c8b250d8938f4978343f3";
    sha256 = "113f9ypwaibk0xwm1sgq9yhr9dp1z2c59zfsafxxhwl58b5zi8jg";
  };

  preConfigure = ''
    patchShebangs ./configure
    sed -e '/ARPDDIR/d' -i Makefile
  '';

  makeFlags = [
    "DESTDIR="
    "LIBDIR=$(out)/lib"
    "SBINDIR=$(out)/sbin"
    "MANDIR=$(out)/share/man"
    "BASH_COMPDIR=$(out)/share/bash-completion/completions"
    "DOCDIR=$(TMPDIR)/share/doc/${name}" # Don't install docs
    "HDRDIR=$(TMPDIR)/include/iproute2" # Don't install headers
  ];

  buildFlags = [
    "CONFDIR=/etc/iproute2"
  ];

  installFlags = [
    "CONFDIR=$(out)/etc/iproute2"
  ];

  buildInputs = [ db iptables ];
  nativeBuildInputs = [ bison flex pkgconfig ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = https://wiki.linuxfoundation.org/networking/iproute2;
    description = "A collection of utilities for controlling TCP/IP networking and traffic control in Linux";
    platforms = platforms.linux;
    license = licenses.gpl2;
    maintainers = with maintainers; [ eelco wkennington fpletz ];
  };
}
