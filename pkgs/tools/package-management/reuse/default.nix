{ lib, buildPythonApplication, fetchFromGitLab, debian, pygit2, pytest, jinja2 }:

buildPythonApplication rec {
  pname = "reuse";
  version = "0.3.3";

  src = fetchFromGitLab {
    owner = "reuse";
    repo = "reuse";
    rev = "v${version}";
    sha256 = "1krc9555h3krcfn8ghv39gpjs258v2639sm4ra1k3bkzi5iwnjzf";
  };

  propagatedBuildInputs = [ debian pygit2 ];

  checkInputs = [ pytest jinja2 ];

  # Some path based tests are currently broken under nix
  checkPhase = ''
    pytest tests -k "not test_lint_none and not test_lint_ignore_debian and not test_lint_twice_path"
  '';

  meta = with lib; {
    description = "A tool for compliance with the REUSE Initiative recommendations";
    license = with licenses; [ cc-by-sa-40 cc0 gpl3 ];
    maintainers = [ maintainers.FlorianFranzen ];
  };
}
