{ stdenv, buildPythonPackage, fetchPypi, setuptools_scm }:
buildPythonPackage rec {
  pname = "setuptools_scm_git_archive";
  version = "1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1nii1sz5jq75ilf18bjnr11l9rz1lvdmyk66bxl7q90qan85yhjj";
  };

  propagatedBuildInputs = [
    setuptools_scm
  ];

  doCheck = false;

  meta = with stdenv.lib; {
    homepage = https://github.com/Changaco/setuptools_scm_git_archive/;
    description = "setuptools_scm plugin for git archives";
    license = licenses.mit;
    maintainers = with maintainers; [ rvolosatovs ];
  };
}
