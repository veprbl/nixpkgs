{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "dyncall-${version}";
  version = "1.0";

  src = fetchurl {
    url = http://www.dyncall.org/r1.0/dyncall-1.0.tar.gz;
    # http://www.dyncall.org/r1.0/SHA256
    sha256 = "d1b6d9753d67dcd4d9ea0708ed4a3018fb5bfc1eca5f37537fba2bc4f90748f2";
  };

  doCheck = false;
  checkTarget = "run-tests";

  # install bits not automatically installed
  postInstall = ''
    # install cmake modules to make using dyncall easier
    # This is essentially what -DINSTALL_CMAKE_MODULES=ON if using cmake build
    # (which we don't since it doesn't have a target for running tests AFAICT)
    install -D -t $out/lib/cmake ./buildsys/cmake/Modules/Find*.cmake

    # manpages are nice, install them
    install -D -t $out/share/man/man3 ./*/*.3
  '';

  meta = with stdenv.lib; {
    description = "Highly dynamic multi-platform foreign function call interface library";
    homepage = http://www.dyncall.org;
    license = licenses.isc;
    maintainers = with maintainers; [ dtzWill ];
  };
}
