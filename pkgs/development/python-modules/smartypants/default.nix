{ lib
, buildPythonPackage
, fetchFromGitHub
, isPyPy
, pytestCheckHook
, docutils
, pygments
}:

buildPythonPackage rec {
  version = "2.0.1";
  pname = "smartypants";
  disabled = isPyPy;

  src = fetchFromGitHub {
    owner = "leohemsted";
    repo = "smartypants.py";
    rev = "v${version}";
    sha256 = "sha256-V1rV1B8jVADkS0NhnDkoVz8xxkqrsIHb1mP9m5Z94QI=";
  };

  checkInputs = [ pytestCheckHook docutils pygments ];
  preCheck = ''
    substituteInPlace tests/test_cli.py \
      --replace "CLI_SCRIPT = " "CLI_SCRIPT = \"$out/bin/smartypants\" #"
  '';

  meta = with lib; {
    description = "Python with the SmartyPants";
    homepage = "https://github.com/leohemsted/smartypants.py";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };

}
