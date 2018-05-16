{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "dyncall-${version}";
  version = "1.0";

  src = fetchurl {
    url = http://www.dyncall.org/r1.0/dyncall-1.0.tar.gz;
    # http://www.dyncall.org/r1.0/SHA256
    sha256 = "d1b6d9753d67dcd4d9ea0708ed4a3018fb5bfc1eca5f37537fba2bc4f90748f2";
  };

  postPatch = stdenv.lib.optionalString stdenv.hostPlatform.isx86_64 ''
    # Remove syscall test on x86_64, not yet implemented (see ToDo)
    substituteInPlace test/Makefile.generic \
      --replace " syscall nm dynload_plain" " nm dynload_plain"
  '' + ''
    sed -i '2iset -exE' test/run-build.sh
    patchShebangs test/run-build.sh
    cat test/run-build.sh

    # don't pipe test output through grep,
    # this causes failures to be ignored since not pipefail
    substituteInPlace test/Makefile.generic \
      --replace '| grep "result:"' ""

    # Remove "nm" test, needs to be invoked with argument
    substituteInPlace test/Makefile.generic \
      --replace " nm dynload_plain" " dynload_plain"

    # Yikes
    substituteInPlace test/dynload_plain/Makefile.generic \
      --replace '-DDEF_C_DYLIB=\"''${DEF_C_DYLIB}\"' '-DDEF_C_DYLIB=\"${stdenv.cc.libc}/lib/libc.so.6\"'
  '';

  hardeningDisable = [ "all" ];

  doCheck = true;
  preCheck = ''
    export hardeningDisable=all
  '';
  checkTarget = "run-tests";

  # install bits not automatically installed
  postInstall = ''
    # install cmake modules to make using dyncall easier
    # This is essentially what -DINSTALL_CMAKE_MODULES=ON if using cmake build
    # We don't use the cmake-based build since it installs different set of headers
    # (mostly fewer headers, but installs dyncall_alloc_wx.h "instead" dyncall_alloc.h)
    # and we'd have to patch the cmake module installation to not use CMAKE_ROOT anyway :).
    install -D -t $out/lib/cmake ./buildsys/cmake/Modules/Find*.cmake

    # manpages are nice, install them
    # doing this is in the project's "ToDo", so check this when updating!
    install -D -t $out/share/man/man3 ./*/*.3
  '';

  meta = with stdenv.lib; {
    description = "Highly dynamic multi-platform foreign function call interface library";
    homepage = http://www.dyncall.org;
    license = licenses.isc;
    maintainers = with maintainers; [ dtzWill ];
  };
}
