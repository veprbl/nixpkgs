{ stdenv, buildPythonPackage, fetchFromGitHub, fetchpatch, glibcLocales }:

buildPythonPackage (rec {
  pname = "urwid";
  version = "2018-12-10";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "5b54344288fd4f2e18d2f837072803d8c26bb85f";
    sha256 = "117fb5x429jv6d70aqdswqgz5nr2fninmsb17kcamw8yk9l8mbk8";
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
