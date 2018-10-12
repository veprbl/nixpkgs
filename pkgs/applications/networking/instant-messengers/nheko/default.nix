{ lib, stdenv, fetchFromGitHub, fetchurl
, cmake, cmark, lmdb, qt5, qtmacextras, mtxclient
, boost, spdlog, olm, pkgconfig
}:

let
  tweeny = fetchFromGitHub {
    owner = "mobius3";
    repo = "tweeny";
    rev = "5e683d735be18427f7b5736f590cd12e71911f97";
    sha256 = "1w381zf0k4cn8jxm492ib7mgr06ybjg2gbfak5map8ixixnsyjmp";
  };

  lmdbxx = fetchFromGitHub {
    owner = "bendiken";
    repo = "lmdbxx";
    rev = "0b43ca87d8cfabba392dfe884eb1edb83874de02";
    sha256 = "1whsc5cybf9rmgyaj6qjji03fv5jbgcgygp956s3835b9f9cjg1n";
  };
in
stdenv.mkDerivation rec {
  name = "nheko-${version}";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "mujx";
    repo = "nheko";
    rev = "v${version}";
    sha256 = "014k68mmw3ys7ldgj96kkr1i1lyv2nk89wndkqznsizcr3097fn5";
  };

  # If, on Darwin, you encounter the error
  #   error: must specify at least one argument for '...' parameter of variadic
  #   macro [-Werror,-Wgnu-zero-variadic-macro-arguments]
  # Then adding this parameter is likely the fix you want.
  #
  # However, it looks like either cmake doesn't honor this CFLAGS variable, or
  # darwin's compiler doesn't have the same syntax as gcc for turning off
  # -Werror selectively.
  #
  # Anyway, this is something that will have to be debugged with access to a
  # darwin-based OS. Sorry about that!
  #
  #preConfigure = lib.optionalString stdenv.isDarwin ''
  #  export CFLAGS=-Wno-error=gnu-zero-variadic-macro-arguments
  #'';

  postPatch = ''
    mkdir -p .deps/include/
    ln -s ${tweeny}/include .deps/include/tweeny
    ln -s ${spdlog} .deps/spdlog
  '';

  cmakeFlags = [
    "-DTWEENY_INCLUDE_DIR=.deps/include"
    "-DLMDBXX_INCLUDE_DIR=${lmdbxx}"
  ];

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [
    mtxclient olm boost lmdb spdlog cmark
    qt5.qtbase qt5.qtmultimedia qt5.qttools
  ] ++ lib.optional stdenv.isDarwin qtmacextras;

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Desktop client for the Matrix protocol";
    maintainers = with maintainers; [ ekleog fpletz ];
    platforms = platforms.unix;
    license = licenses.gpl3Plus;
    knownVulnerabilities = [ "No longer maintained" ];
  };
}
