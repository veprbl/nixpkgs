{ lib, python2 }:

python2.pkgs.buildPythonApplication rec {
  pname = "lit";
  version = "0.7.0";

  src = python2.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "1c74a9i52h532gz7ccp89h5jrjdb14b9s7m9pprbn4ir3cgjzcqk";
  };

  # Non-standard test suite. Needs custom checkPhase.
  doCheck = false;

  meta = {
    description = "Portable tool for executing LLVM and Clang style test suites";
    homepage = http://llvm.org/docs/CommandGuide/lit.html;
    license = lib.licenses.ncsa;
    maintainers = with lib.maintainers; [ dtzWill ];
  };
}
