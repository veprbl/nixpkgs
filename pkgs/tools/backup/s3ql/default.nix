{ stdenv, fetchFromGitHub, python3Packages, sqlite, which }:

python3Packages.buildPythonApplication rec {
  name = "${pname}-${version}";
  pname = "s3ql";
  version = "2.33";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "release-${version}";
    sha256 = "1xrm4pliajdppvi6a4km79qpqwxh2jk786c43aqb1c518gxaib90";
  };

  buildInputs = [ which ]; # tests will fail without which
  propagatedBuildInputs = with python3Packages; [
    sqlite apsw pycrypto requests defusedxml dugong llfuse
    cython pytest pytest-catchlog
  ];

  checkPhase = ''
    pytest tests
  '';

  meta = with stdenv.lib; {
    description = "A full-featured file system for online data storage";
    homepage = https://github.com/s3ql/s3ql;
    license = licenses.gpl3;
    maintainers = with maintainers; [ rushmorem ];
    platforms = platforms.linux;
  };
}
