{ stdenv, lib, fetchFromGitHub }:
stdenv.mkDerivation {
  name = "webmusl";

  src = fetchFromGitHub {
    owner = "jfbastien";
    repo = "musl";
    rev = "16d3d3825b4bd125244e43826fb0f0da79a1a4ad";
    sha256 = "1lqdi3702ibscvzk5vrcai9g1x6dczwgq3isn2a17yv8san01rlw";
  };

  enableParallelBuilding = true;

  configureFlags = [
    "--enable-shared"
    "--enable-static"
    "--enable-debug"
    "--disable-wrapper"
  ];

  dontDisableStatic = true;
  separateDebugInfo = true;

  NIX_DONT_SET_RPATH = true;

  meta = {
    description = "Musl for the web";
    license     = lib.licenses.mit;
    platforms   = lib.platforms.wasm;
    maintainers = [ lib.maintainers.matthewbauer ];
  };
}
