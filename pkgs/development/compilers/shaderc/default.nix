{ stdenv, fetchFromGitHub, cmake, python }:
# Like many google projects, shaderc doesn't gracefully support separately compiled dependencies, so we can't easily use
# the versions of glslang and spirv-tools used by vulkan-loader. Exact revisions are taken from
# https://github.com/google/shaderc/blob/known-good/known_good.json

# Future work: extract and fetch all revisions automatically based on a revision of shaderc's known-good branch.
let
  glslang = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "glslang";
    rev = "e3cc0d35f32ed4cbfb161a1518f986f969ae27f6";
    sha256 = "118g5xp1aym468kmhj4kx206v69fb42s6l7wg6zdbr377dslxgad";
  };
  spirv-tools = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Tools";
    rev = "a29a9947ac96d811b310f481b24e293f67fedf32";
    sha256 = "0z63smmdlznyplvx35ja7f6qfhpm6wvqbmzm3lkr958pk63ccaqv";
  };
  spirv-headers = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Headers";
    rev = "a2c529b5dda18838ab4b52f816acfebd774eaab3";
    sha256 = "1cywa5j006lrp0n3xrccmr6rikbdvlwxswqwp1apgp8m5ll8msqh";
  };
in stdenv.mkDerivation rec {
  name = "shaderc-${version}";
  version = "2018-11-13";

  src = fetchFromGitHub {
    owner = "google";
    repo = "shaderc";
    rev = "823901b2803d9d70c4e0975daa8600c6500b5274";
    sha256 = "1px2jaj0lil5gg5vyns8m38yc97xj9x63518788bbnwbbph9lxb7";
  };

  patchPhase = ''
    cp -r --no-preserve=mode ${glslang} third_party/glslang
    cp -r --no-preserve=mode ${spirv-tools} third_party/spirv-tools
    ln -s ${spirv-headers} third_party/spirv-tools/external/spirv-headers
  '';

  buildInputs = [ cmake python ];
  enableParallelBuilding = true;

  cmakeFlags = [ "-DSHADERC_SKIP_TESTS=ON" ];

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "A collection of tools, libraries and tests for shader compilation.";
  };
}
