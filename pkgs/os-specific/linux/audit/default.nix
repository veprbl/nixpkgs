{
  stdenv, buildPackages, fetchurl, fetchpatch,
  enablePython ? false, python ? null,
}:

assert enablePython -> python != null;

stdenv.mkDerivation rec {
  pname = "audit";
  version = "2.8.5";

  src = fetchurl {
    url = "https://people.redhat.com/sgrubb/${pname}/${pname}-${version}.tar.gz";
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
  ];

  enableParallelBuilding = true;

  patches = [
    (fetchpatch {
      url = "https://github.com/linux-audit/audit-userspace/commit/d579a08bb1cde71f939c13ac6b2261052ae9f77e.patch";
      sha256 = "015bvzflg1s1k5viap30nznlpjj44a66khyc8yq0waa68qwvdlsd";
    })
  ];

  meta = {
    description = "Audit Library";
    homepage = https://people.redhat.com/sgrubb/audit/;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ fuuzetsu ];
  };
}
