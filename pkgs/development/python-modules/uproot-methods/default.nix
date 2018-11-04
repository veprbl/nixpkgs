{ stdenv
, buildPythonPackage
, fetchPypi
, numpy
, awkward
}:

buildPythonPackage rec {
  version = "0.2.6";
  pname = "uproot-methods";

  src = fetchPypi {
    inherit pname version;
    sha256 = "b653f3418f3ee6b9c031c711b69a6c23ab791b20a4ff6f50f9c85ce4ac7a0ffd";
  };

  propagatedBuildInputs = [ numpy awkward ];

  meta = with stdenv.lib; {
    homepage = https://github.com/scikit-hep/uproot-methods;
    description = "Pythonic mix-ins for ROOT classes";
    license = licenses.bsd3;
    maintainers = [ maintainers.costrouc ];
  };
}
