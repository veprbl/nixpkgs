{ stdenv, fetchFromGitHub, cmake, python }:

let

spirv_sources = {
  # `glslang` requires a specific version of `spirv-tools` and `spirv-headers` as specified in `known-good.json`.
  tools = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Tools";
    rev = "24328a0554654d9e205b532288044d6d203c3f2c";
    sha256 = "0dnyqrqjgk8gsh9y8g63wgdhabh4m0af233xpd3fzj7v2z9qv13m";
  };
  headers = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "SPIRV-Headers";
    rev = "17da9f8231f78cf519b4958c2229463a63ead9e2";
    sha256 = "0a5s6g8wglivpcjkf3rwbqkzdqwxaglxyzwynx3x42b1qmjkiipd";
  };
};

in

stdenv.mkDerivation rec {
  name = "spirv-tools-${version}";
  version = "2018-12-11";

  src = spirv_sources.tools;
  patchPhase = ''ln -sv ${spirv_sources.headers} external/spirv-headers'';
  enableParallelBuilding = true;

  buildInputs = [ cmake python ];

  passthru = {
    headers = spirv_sources.headers;
  };

  meta = with stdenv.lib; {
    inherit (src.meta) homepage;
    description = "The SPIR-V Tools project provides an API and commands for processing SPIR-V modules";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = [ maintainers.ralith ];
  };
}
