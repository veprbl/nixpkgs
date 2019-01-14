{ buildPythonPackage
, fetchPypi
# See README.rst regarding "extras" and preferred deps
, scipy
, lxml
, fs
, pygobject3
, gtk3
, gobject-introspection
, wrapGAppsHook
, pytest
, pytestrunner
, glibcLocales
}:

buildPythonPackage rec {
  pname = "fonttools";
  version = "3.35.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1z7gzkcg6423rdf2z8zb3ryyv00w53ma0894mzzdh2s7vdbc3lyn";
    extension = "zip";
  };

  buildInputs = [
    scipy lxml fs
    gtk3
    gobject-introspection
    wrapGAppsHook
  ];

  propagatedBuildInputs = [
    pygobject3
  ];

  checkInputs = [
    pytest
    pytestrunner
    glibcLocales
  ];

  preCheck = ''
    export LC_ALL="en_US.UTF-8"
  '';

  meta = {
    homepage = https://github.com/fonttools/fonttools;
    description = "A library to manipulate font files from Python";
  };
}
