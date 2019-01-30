{ stdenv, lib, buildPythonApplication, fetchFromGitHub, pexpect, urwid, toml, pydantic, glibcLocales }:

buildPythonApplication rec {
  pname = "just-start";
  version = "2018-10-25";

  src = fetchFromGitHub {
    owner = "AliGhahraei";
    repo = pname;
    rev = "e24310a8fb4e2962702a0fbb9509615efad15c66";
    sha256 = "0vm3jp3a8nibmbgik2daq4wb437qrc2ri2zwb3c49rnl6y7dw258";
  };

  propagatedBuildInputs = [ pexpect urwid toml pydantic ];

  checkInputs = [ glibcLocales ];

  LC_ALL = "C.UTF-8";

  # Fails with message complaining about our fake $HOME
  doCheck = false;

  meta = with lib; {
    description = "An app to defeat procrastination (terminal pomodoro w/taskwarrior)";
    license = licenses.gpl3;
    homepage = https://github.com/AliGhahraei/just-start;
    maintainers = with maintainers; [ dtzWill ];
  };
}
