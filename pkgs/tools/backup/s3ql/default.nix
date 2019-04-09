{ stdenv, fetchFromGitHub, python3Packages, sqlite, which }:

python3Packages.buildPythonApplication rec {
  pname = "s3ql";
  version = "3.1";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "release-${version}";
    sha256 = "0w24pvhfqbdkkx2mr3b7ilb7ni7naafz7zhlw99c56pv6nb54swl";
  };

  nativeBuildInputs = [ python3Packages.cython which ]; # tests will fail without which
  propagatedBuildInputs = with python3Packages; [
    sqlite apsw cryptography requests defusedxml dugong llfuse
    google_auth google-auth-oauthlib
    cython pytest pytest-catchlog
  ];

  preBuild = ''
    # https://bitbucket.org/nikratio/s3ql/issues/118/no-module-named-s3qldeltadump-running#comment-16951851
    ${python3Packages.python.interpreter} ./setup.py build_cython build_ext --inplace
  '';

  preCheck = ''
    # fix s3qladm test failing when trying to access ~/.s3ql
    export HOME=$PWD/test-home
    mkdir -p $HOME
  '';

  meta = with stdenv.lib; {
    description = "A full-featured file system for online data storage";
    homepage = https://github.com/s3ql/s3ql;
    license = licenses.gpl3;
    maintainers = with maintainers; [ rushmorem ];
    platforms = platforms.linux;
  };
}
