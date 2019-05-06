{ stdenv, lib, fetchurl, extra-cmake-modules
, qtbase, kdeFrameworks
, libatasmart, parted
, utillinux }:

let
  pname = "kpmcore";

in stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  version = "4.0.0";

  src = fetchurl {
    url = "mirror://kde/stable/${pname}/${version}/src/${name}.tar.xz";
    sha256 = "0vfz9pr9n6p9hs3d9cm8yirp9mkw76nhnin55v3bwsb34p549w6p";
  };

  buildInputs = [
    qtbase
    libatasmart
    parted # we only need the library

    kdeFrameworks.kio

    utillinux # needs blkid (note that this is not provided by utillinux-compat)
  ];
  nativeBuildInputs = [ extra-cmake-modules ];
  enableParallelBuilding = true;

  meta = with stdenv.lib; {
   maintainers = with lib.maintainers; [ peterhoeg ];
  };
}
