{ stdenv, python3Packages, notmuch, fetchgit, git }:

python3Packages.buildPythonApplication rec {
  pname = "afew";
  version = "1.3.0.99-git"; # not really

  src = fetchgit {
    url = https://github.com/afewmail/afew;
    rev = "3bb53dbb90b0725f0976027f8ce5ff7181f78398";
    sha256 = "0bmngl98wz4qwby122b42dpvhd7wifcs2q0s7vx10d10rif5bwzx";
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

  SETUPTOOLS_SCM_PRETEND_VERSION = version;
  setupPyBuildFlags = [ "build_sphinx" "-b" "man,html" ];

  outputs = [ "out" "man" "doc" ];

  postInstall = ''
    install -Dt $out/share/man/man1 build/sphinx/man/*
    mkdir -p $out/share/doc/
    cp -r build/sphinx/html $out/share/doc/afew
  '';

  makeWrapperArgs = [
    "--prefix" "PATH" ":" "${notmuch}/bin"
  ];

  meta = with stdenv.lib; {
    outputsToInstall = outputs;
    homepage = https://github.com/afewmail/afew;
    description = "An initial tagging script for notmuch mail";
    license = licenses.isc;
    maintainers = with maintainers; [ garbas andir flokli ];
  };
}
