{ stdenv, buildPythonPackage, fetchPypi, isPy26, argparse, attrs, hypothesis, py
, setuptools_scm, setuptools, six, pluggy, funcsigs, isPy3k
}:
buildPythonPackage rec {
  version = "3.4.2";
  pname = "pytest";

  preCheck = ''
    # don't test bash builtins
    rm testing/test_argcomplete.py
  '';

  src = fetchPypi {
    inherit pname version;
    sha256 = "117bad36c1a787e1a8a659df35de53ba05f9f3398fb9e4ac17e80ad5903eb8c5";
  };

  checkInputs = [ hypothesis ];
  buildInputs = [ setuptools_scm ];
  propagatedBuildInputs = [ attrs py setuptools six pluggy ]
    ++ (stdenv.lib.optional (!isPy3k) funcsigs)
    ++ (stdenv.lib.optional isPy26 argparse);

  meta = with stdenv.lib; {
    maintainers = with maintainers; [ domenkozar lovek323 madjar lsix ];
    platforms = platforms.unix;
    description = "Framework for writing tests";
  };
}
