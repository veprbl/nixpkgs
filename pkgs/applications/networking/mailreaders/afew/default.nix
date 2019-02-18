{ stdenv, python3Packages, notmuch, fetchgit, git }:

python3Packages.buildPythonApplication rec {
  pname = "afew";
  version = "1.3.0.99-git"; # not really

  src = fetchgit {
    url = https://github.com/afewmail/afew;
    rev = "5f405f033e674703e97d66777a9ac6f2e5dffaa8";
    sha256 = "18ickcnz4zqkqd0xraqg7k1mk4qbrzn46g81pc6sw036vdmdv96z";
    leaveDotGit = true;
  };
  #src = pythonPackages.fetchPypi {
  #  inherit pname version;
  #  sha256 = "0105glmlkpkjqbz350dxxasvlfx9dk0him9vwbl86andzi106ygz";
  #};

  nativeBuildInputs = with python3Packages; [ sphinx setuptools_scm git ];

  propagatedBuildInputs = with python3Packages; [
    python3Packages.notmuch chardet dkimpy
  ];

  postBuild =  ''
    make -C docs man
  '';

  postInstall = ''
    mandir="$out/share/man/man1"
    mkdir -p "$mandir"
    cp docs/build/man/* "$mandir"
  '';

  makeWrapperArgs = [
    ''--prefix PATH ':' "${notmuch}/bin"''
  ];

  meta = with stdenv.lib; {
    homepage = https://github.com/afewmail/afew;
    description = "An initial tagging script for notmuch mail";
    license = licenses.isc;
    maintainers = with maintainers; [ garbas andir flokli ];
  };
}
