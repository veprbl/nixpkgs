{
  stdenv, buildPackages, fetchurl,
  enablePython ? false, python ? null,
}:

assert enablePython -> python != null;

stdenv.mkDerivation rec {
  name = "audit-2.8.1";

  src = fetchurl {
    url = "http://people.redhat.com/sgrubb/audit/${name}.tar.gz";
    sha256 = "0v1vng43fjsh158zb5k5d81ngn4p4jmj1247m27pk0bfzy9dxv0v";
  };

  outputs = [ "bin" "dev" "out" "man" ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  buildInputs = stdenv.lib.optional enablePython python;

  configureFlags = [
    # z/OS plugin is not useful on Linux,
    # and pulls in an extra openldap dependency otherwise
    "--disable-zos-remote"
    (if enablePython then "--with-python" else "--without-python")
  ];

  enableParallelBuilding = true;

  patches = stdenv.lib.optional stdenv.isMusl [
    #./0001-auditctl-include-headers-to-make-build-work-with-mus.patch
    ./0002-auparse-remove-use-of-rawmemchr.patch
    ./0003-all-get-rid-of-strndupa.patch
  ];

  prePatch = ''
    sed -i 's,#include <sys/poll.h>,#include <poll.h>\n#include <limits.h>,' audisp/audispd.c
  '';
  meta = {
    description = "Audit Library";
    homepage = http://people.redhat.com/sgrubb/audit/;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ fuuzetsu ];
  };
}
