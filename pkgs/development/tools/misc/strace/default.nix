{ stdenv, fetchurl, perl, libunwind }:

stdenv.mkDerivation rec {
  name = "strace-${version}";
  version = "4.20";

  src = fetchurl {
    url = "mirror://sourceforge/strace/${name}.tar.xz";
    sha256 = "08y5b07vb8jc7ak5xc3x2kx1ly6xiwv1gnppcqjs81kks66i9wsv";
  };

  nativeBuildInputs = [ perl ];

  buildInputs = [ libunwind ]; # support -k

  # Kludge to fix conflict with kernel headers, libc-compat.h only checks for GLIBC
  # http://www.openwall.com/lists/musl/2015/10/08/2
  postPatch = stdenv.lib.optionalString stdenv.isMusl ''
    sed -i -e 's@# include <netinet/in.h>@\0\n#define __GLIBC__ 1\n@' rtnl_mdb.c
  '';

  meta = with stdenv.lib; {
    homepage = http://strace.sourceforge.net/;
    description = "A system call tracer for Linux";
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mornfall jgeerds globin ];
  };
}
