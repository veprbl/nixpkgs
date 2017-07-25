{ stdenv, fetchFromGitHub, python, snowman, ninja
, timeout ? 300
, failuresOk ? false }:

stdenv.mkDerivation rec {
  name = "snowman-tests-${version}";
  version = "2017-02-18";
  src = fetchFromGitHub {
    owner = "yegord";
    repo = "snowman-tests";
    rev = "32c2c4a121c2805c00ca543297261b80cf6df4b9";
    sha256 = "0dc70livd8gvc8nmp6g3jyn8scl1h2vvdg61h6dqy9w747xnzpk5";
  };

  nativeBuildInputs = [ python ninja ];

  prePatch = ''
    patchShebangs *.py

    substituteInPlace rules.ninja --replace "timeout = 300" "timeout = ${builtins.toString timeout}"
  '' +
  # Remove tests that take too long, not sure if they finish in reasonable time for others or not
  # https://github.com/yegord/snowman/issues/64
  ''
    rm debian-armel/sha384sum
    rm debian-armel/sha512sum
  '';

  configurePhase = ''
    mkdir $PWD/build
    cd build
    ../configure.py --decompiler ${snowman}/bin/nocode .
  '';

  buildPhase = ''
    (ninja -j''${NIX_BUILD_CORES:-1} decompile -k 100 || ${if failuresOk then ":" else "exit $?"}) |& tee decompile.log
    ninja -j1 check |& tee check.log
  '';

  installPhase = ''
    mkdir -p $out

    mv decompile.log check.log $out/
  '';

  meta = with stdenv.lib; {
    description = "Test Snowman decompiler on various binaries";
    homepage = "https://github.com/yegord/snowman-tests";
    license = licenses.beerware; # Actually it's "juiceware" but otherwise text is identical
    platforms = platforms.all;
    maintainers = with maintainers; [ dtzWill ];
  };
}
