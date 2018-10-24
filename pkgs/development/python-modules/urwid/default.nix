{ stdenv, buildPythonPackage, fetchFromGitHub, fetchpatch, glibcLocales }:

buildPythonPackage (rec {
  pname = "urwid";
  version = "2018-03-13";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "16469df346bc4b4b7a1035e06048bb6f5d9aa111";
    sha256 = "1xcfxsgnzjhsx0zbgrhh74zm34fxqbqnk31k4c9h2b7g0l77gwmb";
  };

  #propagatedBuildInputs = [ glibcLocales ];
  checkInputs = [ glibcLocales ];

  meta = with stdenv.lib; {
    description = "A full-featured console (xterm et al.) user interface library";
    homepage = http://excess.org/urwid;
    repositories.git = git://github.com/wardi/urwid.git;
    license = licenses.lgpl21;
    maintainers = with maintainers; [ garbas ];
  };
})
