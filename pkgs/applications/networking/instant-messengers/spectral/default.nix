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
  version = "2018-10-07";

  src = fetchgit {
    url = "https://gitlab.com/b0/spectral.git";
    rev = "e69ac60d08bc7424e1713d39fbfd8513c6ef5dca";
    sha256 = "144lrwhyql69ws3c97mxqlwlrxqnij53h79i4wbb6axzxc7sriif";
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
