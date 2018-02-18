{ stdenv, fetchFromGitHub, fetchpatch, qmake, pkgconfig, qtbase, qtsvg, radare2 }:

let
  r2-git = radare2.overrideAttrs(o: {
    version = "2018-02-11";
    src = fetchFromGitHub {
      owner = "radare";
      repo = "radare2";
      rev = "145b7aceac7807a0df515d959551dae99344cd1c";
      sha256 = "1z6vh2wcn2i4pq0nfvmwi9kfgzm321z4hqssq69r7wk3cajbnq86";
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
