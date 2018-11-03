{ stdenv
, buildPythonPackage
, fetchPypi
, pytest
, six
, fetchpatch
, pkgs
}:

buildPythonPackage rec {
  pname = "PyICU";
  version = "2.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0wq9y5fi1ighgf5aws9nr87vi1w44p7q1k83rx2y3qj5d2xyhspa";
  };

  patches = [
    (fetchpatch {
      url = https://sources.debian.org/data/main/p/pyicu/2.2-1/debian/patches/icu_test.patch;
      sha256 = "1iavdkyqixm9i753svl17barla93b7jzgkw09dn3hnggamx7zwx9";
    })
  ];

  buildInputs = [ pkgs.icu60 pytest ];
  propagatedBuildInputs = [ six ];

  meta = with stdenv.lib; {
    homepage = https://pypi.python.org/pypi/PyICU/;
    description = "Python extension wrapping the ICU C++ API";
    license = licenses.mit;
    platforms = platforms.linux; # Maybe other non-darwin Unix
    maintainers = [ maintainers.rycee ];
  };

}
