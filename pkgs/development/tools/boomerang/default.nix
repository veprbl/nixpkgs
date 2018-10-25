{ stdenv, fetchFromGitHub, cmake, qtbase }:

stdenv.mkDerivation rec {
  name = "boomerang-${version}";
  version = "0.4.0-alpha-2018-10-25";

  src = fetchFromGitHub {
    owner = "BoomerangDecompiler";
    repo = "boomerang";
    rev = "ed7a3e11bff32160fba560448309db6b4de0c194";
    sha256 = "1aa3d5z2symli9d31aj85nl1jjcxd5cgm3ccg9a2wv9qci3g0hvn";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ qtbase ];

  postPatch =
  # Look in installation directory for required files, not relative to working directory
  ''
    substituteInPlace src/boomerang/core/Settings.cpp \
      --replace "setDataDirectory(\"../share/boomerang\");" \
                "setDataDirectory(\"$out/share/boomerang\");" \
      --replace "setPluginDirectory(\"../lib/boomerang/plugins\");" \
                "setPluginDirectory(\"$out/lib/boomerang/plugins\");"
  ''
  # Fixup version:
  # * don't try to inspect with git
  #   (even if we kept .git and such it would be "dirty" because of patching)
  # * use date so version is monotonically increasing moving forward
  + ''
    sed -i cmake-scripts/boomerang-version.cmake \
      -e 's/set(\(PROJECT\|BOOMERANG\)_VERSION ".*")/set(\1_VERSION "${version}")/'
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = https://github.com/BoomerangDecompiler/boomerang;
    license = licenses.bsd3;
    description = "A general, open source, retargetable decompiler";
    maintainers = with maintainers; [ dtzWill ];
  };
}
