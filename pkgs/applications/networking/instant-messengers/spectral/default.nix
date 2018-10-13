{ stdenv, fetchgit
, pkgconfig
, qmake, qtbase, qtquickcontrols2, qtmultimedia
, libpulseaudio
# Not mentioned but seems needed
, qtgraphicaleffects
, qtdeclarative
}:

stdenv.mkDerivation rec {
  name = "spectral-${version}";
  version = "2018-10-13";

  src = fetchgit {
    url = "https://gitlab.com/b0/spectral.git";
    rev = "d9592e4a7c69d00222ef87ad99b3238d3cc27c01";
    sha256 = "08qd6n54s7y9cdfd49x14673cl4xphv81jlazqj9jsdkg03d71c8";
    fetchSubmodules = true;
  };

  # Doesn't seem to work without this, used to be documented in the .pro file.  Dunno.
  qmakeFlags = [ "CONFIG+=qtquickcompiler" ];

  nativeBuildInputs = [ pkgconfig qmake ];
  buildInputs = [ qtbase qtquickcontrols2 qtmultimedia qtgraphicaleffects qtdeclarative ]
    ++ stdenv.lib.optional stdenv.hostPlatform.isLinux libpulseaudio;

  meta = with stdenv.lib; {
    description = "A glossy client for Matrix, written in QtQuick Controls 2 and C++";
    homepage = https://gitlab.com/b0/spectral;
    license = licenses.gpl3;
    platforms = with platforms; linux ++ darwin;
    maintainers = with maintainers; [ dtzWill ];
  };
}
