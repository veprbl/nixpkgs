{ buildPythonPackage, fetchPypi, lib, ujson, email_validator }:

buildPythonPackage rec {
  pname = "pydantic";
  version = "0.18.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1rw2386qkhxxmbpv5miff060lsj6ai5mxwn0fi9m1npyc6shifzd";
  };

  # https://github.com/samuelcolvin/pydantic/issues/376
  postPatch = ''
    substituteInPlace setup.cfg --replace 'py36+' 'py36.py37'
  '';

  buildInputs = [ ujson email_validator ];

  meta = with lib; {
    description = "Data validation and settings management using python type hinting";
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
  };
}
