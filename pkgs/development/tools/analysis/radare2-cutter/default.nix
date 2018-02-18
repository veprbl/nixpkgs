{ stdenv, fetchFromGitHub, fetchpatch, qmake, pkgconfig, qtbase, qtsvg, radare2 }:

let
  r2-git = radare2.overrideAttrs(o: rec {
    name = "radare2-for-cutter-${version}";
    version = "2018-02-18";
    src = fetchFromGitHub {
      owner = "radare";
      repo = "radare2";
      rev = "0e247959123aaac5247c885fed0a68d3a327a493";
      sha256 = "15s7b8z05a15b7dbhgrx7s7fiyxxpwi60371cbr6kpzjhscn77b5";
    };
  });
in
stdenv.mkDerivation rec {
  name = "radare2-cutter-${version}";
  version = "2018-02-18";

  src = fetchFromGitHub {
    owner = "radareorg";
    repo = "cutter";
    rev = "0e9be6343b60b2725b3a07b171df55e10a22e933";
    sha256 = "08svpk81shhjygm20z469ydvlsk4kj6nv3imqaki32drr5xxm5qs";
    # fetchSubmodules = true;
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
