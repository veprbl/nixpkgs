{ stdenv, buildPythonPackage, fetchPypi, isPy3k,
  click, jinja2, shellingham, six
}:

buildPythonPackage rec {
  pname = "click-completion";
  version = "0.5.0";
  disabled = (!isPy3k);

  src = fetchPypi {
    inherit pname version;
    sha256 = "7600261cda0954b9794bd7afdaab35201be50a8c5404eaa4c0deb20086866c4c";
  };

  propagatedBuildInputs = [ click jinja2 shellingham six ];

  meta = with stdenv.lib; {
    description = "Add or enhance bash, fish, zsh and powershell completion in Click";
    homepage = https://github.com/click-contrib/click-completion;
    license = licenses.mit;
    maintainers = with maintainers; [ mbode ];
  };
}
