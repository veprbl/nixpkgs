{ stdenv, buildPythonPackage, fetchPypi, setuptools }:

buildPythonPackage rec {
  pname = "bottle";
  version = "0.12.16";

  src = fetchPypi {
    inherit pname version;
    sha256 = "09k733is4whh213yjxryfjlv7k4r320r12kx4nnbdwkx3sk0sccw";
  };

  propagatedBuildInputs = [ setuptools ];

  meta = with stdenv.lib; {
    homepage = http://bottlepy.org;
    description = "A fast and simple micro-framework for small web-applications";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ koral ];
  };
}
