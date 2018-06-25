{ stdenv, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "nbxmpp";
  version = "0.6.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "d0e2830c75c5fa74871995f0be4c5ef2477e696f6ac38b4414170f86bd06e62e";
  };

  meta = with stdenv.lib; {
    homepage = "https://dev.gajim.org/gajim/python-nbxmpp";
    description = "Non-blocking Jabber/XMPP module";
    license = licenses.gpl3;
  };
}
