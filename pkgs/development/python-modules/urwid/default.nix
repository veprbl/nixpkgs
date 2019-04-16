{ stdenv, buildPythonPackage, fetchFromGitHub, fetchpatch, glibcLocales }:

buildPythonPackage (rec {
  pname = "urwid";
  version = "2019-04-16";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "0ea4308af71cbf5973fe81f08c7857f225fdadf6";
    sha256 = "16wbhqh7i6mlv3rw4c79xynjlzpd91bdnakz4wx91pm21lfdr0jw";
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
