{ stdenv
, buildPythonPackage
, fetchPypi
, docutils
, lxml
, manuel
, pygments
, svg-path
, watchdog
, isPy3k
}:

buildPythonPackage rec {
  pname = "hovercraft";
  version = "2.6";
  disabled = ! isPy3k;

  src = fetchPypi {
    inherit pname version;
    sha256 = "e44e29adbb1f7491efe22632e7a0ebf913282b02c5e19efdc33871fc10152acf";
  };

  propagatedBuildInputs = [ docutils lxml manuel pygments svg-path watchdog ];

  # one test assumes we have docutils 0.12
  # TODO: enable tests after upgrading docutils to 0.12
  doCheck = false;

  meta = with stdenv.lib; {
    description = "A tool to make impress.js presentations from reStructuredText";
    homepage = https://github.com/regebro/hovercraft;
    license = licenses.mit;
    maintainers = with maintainers; [ goibhniu ];
  };

}
