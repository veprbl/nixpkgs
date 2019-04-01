{ lib
, python2Packages
, salt
}:

python2Packages.buildPythonApplication rec {
  pname = "salt-pepper";
  version = "0.7.5";
  src = python2Packages.fetchPypi {
    inherit pname version;
    sha256 = "1wh6yidwdk8jvjpr5g3azhqgsk24c5rlzmw6l86dmi0mpvmxm94w";
  };

  buildInputs = with python2Packages; [ setuptools setuptools_scm salt ];
  checkInputs = with python2Packages; [
    pytest mock pyzmq pytest-rerunfailures pytestcov cherrypy tornado_4
  ];

  meta = with lib; {
    description = "A CLI front-end to a running salt-api system";
    homepage = https://github.com/saltstack/pepper;
    maintainers = [ maintainers.pierrer ];
    license = licenses.asl20;
  };
}
