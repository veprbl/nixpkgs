{ stdenv, fetchFromGitHub, fetchpatch, cmake, pkgconfig
, boost, openssl, zlib, libsodium, olm, gtest, spdlog, nlohmann_json }:

stdenv.mkDerivation rec {
  name = "mtxclient-${version}";
  version = "0.2.0-git";

  src = fetchFromGitHub {
    owner = "Nheko-Reborn";
    repo = "mtxclient";
    #rev = "v${version}";
    rev = "6f7b35aa1aea1c1cf96e7aa8168c1c4f53ededec";
    sha256 = "0cvk5vjvlapvjfyrvlhslvmvgk83hqwvndx4yw63niw6jxh62q5j";
  };

  cmakeFlags = [
    "-DBUILD_LIB_TESTS=OFF" "-DBUILD_LIB_EXAMPLES=OFF"
    "-DBUILD_SHARED_LIBS=ON"
  ];

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [ boost openssl nlohmann_json zlib libsodium olm ];

  meta = with stdenv.lib; {
    description = "Client API library for Matrix, built on top of Boost.Asio";
    homepage = https://github.com/mujx/mtxclient;
    license = licenses.mit;
    maintainers = with maintainers; [ fpletz ];
    platforms = platforms.unix;
  };
}
