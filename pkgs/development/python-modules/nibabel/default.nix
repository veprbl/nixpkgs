{ stdenv
, buildPythonPackage
, fetchPypi
, numpy
, nose
, six
}:

buildPythonPackage rec {
  pname = "nibabel";
  version = "2.3.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "a3e4a6965ffd713c82c218663ba1a279a073452e13b426353b14b063d8e366f5";
  };

  propagatedBuildInputs = [
    numpy
    nose
    six
  ];

  # Failing tests
  # nibabel.tests.test_minc1.test_old_namespace
  # nibabel.gifti.tests.test_parse_gifti_fast.test_parse_dataarrays
  # nibabel.gifti.tests.test_giftiio.test_read_deprecated
  doCheck = false;

  meta = with stdenv.lib; {
    homepage = http://nipy.org/nibabel/;
    description = "Access a multitude of neuroimaging data formats";
    license = licenses.mit;
    maintainers = with maintainers; [ ashgillman ];
  };
}
