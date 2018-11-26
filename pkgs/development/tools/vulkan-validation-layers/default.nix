{ stdenv, fetchFromGitHub, cmake, python3, vulkan-headers, vulkan-loader,
  glslang, pkgconfig, xlibsWrapper, libxcb, libXrandr, wayland }:

stdenv.mkDerivation rec {
  name = "vulkan-validation-layers-${version}";
  version = "1.1.92.0";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "Vulkan-ValidationLayers";
    rev = "sdk-${version}";
    sha256 = "02rl00z790kxdqqnyrgdymb888wr9y6ki8azn7arfbvp75v1yn8d";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ cmake python3 vulkan-headers vulkan-loader xlibsWrapper libxcb libXrandr wayland ];
  enableParallelBuilding = true;

  cmakeFlags = [ "-DGLSLANG_INSTALL_DIR=${glslang}" ];

  meta = with stdenv.lib; {
    description = "LunarG Vulkan loader";
    homepage    = https://www.lunarg.com;
    platforms   = platforms.linux;
    license     = licenses.asl20;
    maintainers = [ maintainers.ralith ];
  };
}
