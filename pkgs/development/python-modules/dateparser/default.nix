{ lib, fetchPypi, fetchFromGitHub, buildPythonPackage
, nose
, parameterized
, mock
, glibcLocales
, six
, jdatetime
, dateutil
, umalqurra
, pytz
, tzlocal
, regex
, ruamel_yaml }:

buildPythonPackage rec {
  pname = "dateparser";
  version = "0.7.0.1"; # XXX: not really :(

  # Build from git for py3.7 fixes
  src = fetchFromGitHub {
    owner = "scrapinghub";
    repo = "dateparser";
    rev = "6540c33caaf6923c4affedda2ef92b29f814d6fc";
    sha256 = "1c720hq5m0q7c517fa5675l3knrhgg245dpsq0d9r5hnrw2sgyf3";
  };
  #src = fetchPypi {
  #  inherit pname version;
  #  sha256 = "940828183c937bcec530753211b70f673c0a9aab831e43273489b310538dff86";
  #};

  checkInputs = [ nose mock parameterized six glibcLocales ];
  preCheck =''
    # skip because of missing convertdate module, which is an extra requirement
    rm tests/test_jalali.py
  '';

  propagatedBuildInputs = [
    # install_requires
    dateutil pytz regex tzlocal
    # extra_requires
    jdatetime ruamel_yaml umalqurra
  ];

  meta = with lib; {
    description = "Date parsing library designed to parse dates from HTML pages";
    homepage = https://github.com/scrapinghub/dateparser;
    license = licenses.bsd3;
  };
}
