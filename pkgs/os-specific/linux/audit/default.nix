{
  stdenv, buildPackages, fetchurl, fetchpatch, autoreconfHook,
  enablePython ? false, python ? null,
}:

assert enablePython -> python != null;

stdenv.mkDerivation (rec {
  name = "audit-2.8.5";

  src = fetchurl {
    url = "https://people.redhat.com/sgrubb/audit/${name}.tar.gz";
    sha256 = "1dzcwb2q78q7x41shcachn7f4aksxbxd470yk38zh03fch1l2p8f";
  };

  outputs = [ "bin" "dev" "out" "man" ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  buildInputs = stdenv.lib.optional enablePython python;

  configureFlags = [
    # z/OS plugin is not useful on Linux,
    # and pulls in an extra openldap dependency otherwise
    "--disable-zos-remote"
    (if enablePython then "--with-python" else "--without-python")
    "--with-arm"
    "--with-aarch64"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Audit Library";
    homepage = https://people.redhat.com/sgrubb/audit/;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ fuuzetsu ];
  };
} // stdenv.lib.optionalAttrs stdenv.hostPlatform.isMusl {
  nativeBuildInputs = [ autoreconfHook ];
  patches = [ ./d579a08.patch ];
})
