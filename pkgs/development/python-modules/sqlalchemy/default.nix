{ lib
, fetchPypi
, buildPythonPackage
, pytest
, mock
, isPy3k
, pysqlite
, fetchFromGitHub
}:

buildPythonPackage rec {
  pname = "SQLAlchemy";
  version = "1.2.12";

  src = fetchFromGitHub {
    owner = "zzzeek";
    repo = "sqlalchemy";
    rev = "d945ee87a1934cb689066e4683ba9531d803f9ad";
    sha256 = "1m84npxc63z4dz5j71wsqf0ncz8kal23df3qr127c0jlykwp7pf2";
  };
  #src = fetchPypi {
  #  inherit pname version;
  #  sha256 = "c5951d9ef1d5404ed04bae5a16b60a0779087378928f997a294d1229c6ca4d3e";
  #};

  checkInputs = [
    pytest
    mock
#     Disable pytest_xdist tests for now, because our version seems to be too new.
#     pytest_xdist
  ] ++ lib.optional (!isPy3k) pysqlite;

  checkPhase = ''
    py.test -k "not test_round_trip_direct_type_affinity"
  '';

  meta = with lib; {
    homepage = http://www.sqlalchemy.org/;
    description = "A Python SQL toolkit and Object Relational Mapper";
    license = licenses.mit;
  };
}
