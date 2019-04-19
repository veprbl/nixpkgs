{ stdenv, lib, buildPythonApplication, fetchFromGitHub, isPy3k, pexpect, urwid, toml, pydantic, poetry
, pytest, pytest-mock, coverage
 }:

buildPythonApplication rec {
  pname = "just-start";
  version = "2019-04-18";

  src = fetchFromGitHub {
    owner = "AliGhahraei";
    repo = pname;
    rev = "f7319b34df7bdda2a8517feebfb79ecaa30821af";
    sha256 = "0ba9llimmnhjlsnmb2zz8w4kqc0gwkshyivnjwf5lb380n5wdmsl";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'pydantic = "^0.21.0"' \
                'pydantic = ">=0.21.0"'
  '';

  format = "pyproject";

  buildInputs = [ poetry ];
  propagatedBuildInputs = [ pexpect urwid toml pydantic ];

  LC_ALL = "C.UTF-8";

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  checkInputs = [ pytest pytest-mock coverage ];
  doCheck = false; # check phase?

  disabled = !isPy3k;

  meta = with lib; {
    description = "An app to defeat procrastination (terminal pomodoro w/taskwarrior)";
    license = licenses.gpl3;
    homepage = https://github.com/AliGhahraei/just-start;
    maintainers = with maintainers; [ dtzWill ];
  };
}
