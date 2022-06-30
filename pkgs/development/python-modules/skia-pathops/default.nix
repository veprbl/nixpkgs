{ lib
, buildPythonPackage
, cython
, ninja
, setuptools-scm
, setuptools
, fetchPypi
, gn
, pytestCheckHook
, skia
}:

buildPythonPackage rec {
  pname = "skia-pathops";
  version = "0.7.2";

  src = fetchPypi {
    pname = "skia-pathops";
    inherit version;
    extension = "zip";
    sha256 = "sha256-Gdhcmv77oVr5KxPIiJlk935jgvWPQsYEC0AZ6yjLppA=";
  };

  nativeBuildInputs = [ cython ninja setuptools-scm ];

  propagatedBuildInputs = [ setuptools ];

  buildInputs = [ skia ];

  BUILD_SKIA_FROM_SOURCE=0;

  checkInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "pathops" ];

  meta = {
    description = "Python access to operations on paths using the Skia library";
    homepage = "https://skia.org/dev/present/pathops";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.BarinovMaxim ];
  };
}
