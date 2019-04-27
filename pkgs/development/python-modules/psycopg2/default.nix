{ stdenv, lib, buildPythonPackage, isPyPy, fetchPypi, postgresql, openssl }:

buildPythonPackage rec {
  pname = "psycopg2";
  version = "2.8.2";

  disabled = isPyPy;

  src = fetchPypi {
    inherit pname version;
    sha256 = "122mn2z3r0zgs8jyq682jjjr6vq5690qmxqf22gj6g41dwdz5b2w";
  };

  buildInputs = lib.optional stdenv.isDarwin openssl;
  nativeBuildInputs = [ postgresql ];

  doCheck = false;

  meta = with lib; {
    description = "PostgreSQL database adapter for the Python programming language";
    license = with licenses; [ gpl2 zpl20 ];
  };
}
