{ lib, fetchurl, buildPythonPackage, requests, six, zeroconf, protobuf, casttube, isPy3k }:

buildPythonPackage rec {
  pname = "PyChromecast";
  version = "2.4.0";
  name = pname + "-" + version;

  src = fetchurl {
    url    = "mirror://pypi/p/pychromecast/${name}.tar.gz";
    sha256 = "0q012ghssk2xhm17v28sc2lv62vk7wd5p7zzdbgxk6kywfx8yvm2";
  };

  disabled = !isPy3k;

  propagatedBuildInputs = [ requests six zeroconf protobuf casttube ];

  meta = with lib; {
    description = "Library for Python 3.4+ to communicate with the Google Chromecast";
    homepage    = https://github.com/balloob/pychromecast;
    license     = licenses.mit;
    maintainers = with maintainers; [ abbradar ];
    platforms   = platforms.linux;
  };
}
