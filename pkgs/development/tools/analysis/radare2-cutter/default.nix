{ stdenv, fetchFromGitHub, fetchgit, fetchpatch, qmake, pkgconfig, qtbase, qtsvg, radare2 }:

let
  # Pinned version, submodule
  r2-git = radare2.overrideAttrs(o: rec {
    name = "radare2-for-cutter-${version}";
    version = "2018-03-03";
    src = fetchFromGitHub {
      owner = "radare";
      repo = "radare2";
      rev = "00668df334800762038a77ca666ef46d378650f8";
      sha256 = "07shnhgjfhzyra4nkfzjy0a2smszk1m1w8wawsgbmdxb6l118yvn";
    };

    # Copied from r2, but with updated capstone
    postPatch = let
      cs_tip = "4a1b580d069c82d60070d0869a87000db7cdabe2"; # version from $sourceRoot/shlr/Makefile
      capstone = fetchgit {
        url = "https://github.com/aquynh/capstone.git";
        rev = cs_tip;
        sha256 = "1b126npshdbwh5y7rafmb9w4dzlvxsf4ca6bx4zs2y7kbk48jyn8";
        leaveDotGit = true;
      };
    in ''
      if ! grep -F "CS_TIP=${cs_tip}" shlr/Makefile; then echo "CS_TIP mismatch"; grep CS_TIP= shlr/Makefile; exit 1; fi
      cp -r ${capstone} shlr/capstone
      chmod -R u+rw shlr/capstone
    '';
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
