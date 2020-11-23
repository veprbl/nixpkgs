{ lib
, buildPythonPackage
, fetchPypi
, numpy
, pandas
, pytestrunner
, pytest
, h5py
}:

buildPythonPackage rec {
  pname = "awkward0";
  version = "0.15.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "17c117b27a5981e1e39016bbac89129296f0de74a46a975d19a41ec2c328cd25";
  };

  nativeBuildInputs = [ pytestrunner ];
  checkInputs = [ pandas pytest h5py ];
  propagatedBuildInputs = [ numpy ];

  checkPhase = ''
    py.test
  '';

  meta = with lib; {
    description = "Manipulate jagged, chunky, and/or bitmasked arrays as easily as Numpy";
    homepage = "https://github.com/scikit-hep/awkward-array";
    license = licenses.bsd3;
    maintainers = [ maintainers.costrouc ];
  };
}
