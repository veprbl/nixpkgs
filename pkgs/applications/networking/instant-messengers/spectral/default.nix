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
  version = "2018-10-21";

  src = fetchgit {
    url = "https://gitlab.com/b0/spectral.git";
    rev = "872ff75d6fe7d7b1f9e22b7d3cae43e3f74f80de";
    sha256 = "0n0yg6g07bnfy1rj7plm2wy8ms2jjmwpv1r5ajan6a4kcj13804z";
    fetchSubmodules = true;
  };

  # Doesn't seem to work without this, used to be documented in the .pro file.  Dunno.
  # Update: upstream uses this in CI so it's not just us :)
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
