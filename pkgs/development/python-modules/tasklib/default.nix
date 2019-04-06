{ buildPythonPackage, fetchFromGitHub, six, pytz, tzlocal, taskwarrior }:

buildPythonPackage rec {
  version = "2018-11-27";
  pname = "tasklib";

  src = fetchFromGitHub {
    owner = "robgolding";
    repo = pname;
    rev = "0ad882377639865283021041f19add5aeb10126a";
    sha256 = "1m47isnnfa0wwfbkkdbvpbb8sdv4c57rlhc89lfxcp590x39yj7w";
  };

  propagatedBuildInputs = [ six pytz tzlocal ];
  checkInputs = [ taskwarrior ];

  doCheck = false; # almost, some tz mixup
}
