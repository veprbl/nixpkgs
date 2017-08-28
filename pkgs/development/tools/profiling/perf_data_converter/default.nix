{ stdenv, fetchFromGitHub, pkgconfig, protobuf, openssl, elfutils, zlib }:

stdenv.mkDerivation rec {
  name = "perf_data_converter-${version}";
  version = "2017-08-24";

  src = fetchFromGitHub {
    owner = "google";
    repo = "perf_data_converter";
    rev = "cd397d12317e034ea2dfb2ec396fabe28f0b94be";
    sha256 = "16fb6nyyx7b41i1dz2n16mjq6irbx441wp6b3fr0kh3mdrcfdr2d";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ protobuf openssl elfutils zlib ];

  enableParallelBuilding = true;

  doCheck = false; # bad version of gtest in nixpkgs, probably

  installPhase = ''install -D -t "$out/bin/" ./perf_to_profile'';
}
