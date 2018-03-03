{ stdenv, fetchFromGitHub, fetchpatch, qmake, pkgconfig, qtbase, qtsvg, radare2 }:

let
  # Pinned version, submodule
  r2-git = radare2.overrideAttrs(o: rec {
    name = "radare2-for-cutter-${version}";
    version = "2018-02-26";
    src = fetchFromGitHub {
      owner = "radare";
      repo = "radare2";
      rev = "70bd99da259438fbe552b7debfe68c571cdcd2da";
      sha256 = "1x08xskcz0skhkbgfd98sm7qq6jkniaayavxqjh20gxxcmyhhzfx";
    };
  });
in
stdenv.mkDerivation rec {
  name = "radare2-cutter-${version}";
  version = "2018-03-03";

  src = fetchFromGitHub {
    owner = "radareorg";
    repo = "cutter";
    rev = "78c3e5f1e3113a4ff567f4afb4d317a2eb5ee9e3";
    sha256 = "1ckixifzjd02vd16cr72sbbxzh862y1l1q8malp7a1zj4ca38530";
  };

  postUnpack = "export sourceRoot=$sourceRoot/src";

  nativeBuildInputs = [ qmake pkgconfig ];
  buildInputs = [ qtbase qtsvg r2-git ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A Qt and C++ GUI for radare2 reverse engineering framework";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ dtzWill ];
  };
}
