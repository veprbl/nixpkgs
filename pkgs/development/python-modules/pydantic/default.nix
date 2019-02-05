{ buildPythonPackage, fetchPypi, lib, ujson, email_validator }:

buildPythonPackage rec {
  pname = "pydantic";
  version = "0.19";

  src = fetchPypi {
    inherit pname version;
    sha256 = "7bcc991083c1c0113fd207a4c38f6432d1a640864ac19371e6a18551398f1ae8";
  };

  # https://github.com/samuelcolvin/pydantic/issues/376
  postPatch = ''
    substituteInPlace setup.cfg --replace 'py36+' 'py36.py37'
  '';

  buildInputs = [ ujson email_validator ];

  meta = with lib; {
    description = "Data validation and settings management using python type hinting";
    homepage = https://pydantic-docs.helpmanual.io/;
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
  };
}
