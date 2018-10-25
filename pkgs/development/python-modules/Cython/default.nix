{ lib
, stdenv
, buildPythonPackage
, fetchPypi
, python
, glibcLocales
, pkgconfig
, gdb
, numpy
, ncurses
, fetchpatch
}:

let
  excludedTests = []
    ++ [ "reimport_from_subinterpreter" ]
    # cython's testsuite is not working very well with libc++
    # We are however optimistic about things outside of testsuite still working
    ++ stdenv.lib.optionals (stdenv.cc.isClang or false) [ "cpdef_extern_func" "libcpp_algo" ]
    # Some tests in the test suite isn't working on aarch64. Disable them for
    # now until upstream finds a workaround.
    # Upstream issue here: https://github.com/cython/cython/issues/2308
    ++ stdenv.lib.optionals stdenv.isAarch64 [ "numpy_memoryview" ]
    ++ stdenv.lib.optionals stdenv.isi686 [ "future_division" "overflow_check_longlong" ]
  ;

in buildPythonPackage rec {
  pname = "Cython";
  version = "0.29";

  src = fetchPypi {
    inherit pname version;
    sha256 = "15zama7fgp7yyi3z39xp3z2lvwcgch8fn3ycscw2cs37vqg6v4cl";
  };

  nativeBuildInputs = [
    pkgconfig
  ];
  checkInputs = [
    numpy ncurses
  ];
  buildInputs = [ glibcLocales gdb ];
  LC_ALL = "en_US.UTF-8";

  checkPhase = ''
    export HOME="$NIX_BUILD_TOP"
    ${python.interpreter} runtests.py -j$NIX_BUILD_CORES \
      ${stdenv.lib.optionalString (builtins.length excludedTests != 0)
        ''--exclude="(${builtins.concatStringsSep "|" excludedTests})"''}
  '';

  patches = [
    (fetchpatch {
      name = "exclude-pycodestyle-test-if-not-avail.patch";
      url = https://github.com/cython/cython/commit/5dfefdadf6c20bf631ea3b6e567eede2f1ddd3d0.patch;
      sha256 = "0hdsy2zdc910vhhfckrvnjfli0v766k8s37k203sk557qnhwvica";
    })
  ];

  doCheck = !stdenv.isDarwin;

  meta = {
    description = "An optimising static compiler for both the Python programming language and the extended Cython programming language";
    homepage = http://cython.org;
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fridh ];
  };
}
