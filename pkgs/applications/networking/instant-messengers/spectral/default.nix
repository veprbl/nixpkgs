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
  version = "2018-10-12";

  src = fetchgit {
    url = "https://gitlab.com/b0/spectral.git";
    rev = "99bf32bf913f75abc0311a74b1ec43f4e00e580d";
    sha256 = "10j1n3wdj924zibdg6sfhq9f581znf537150qakyiyp0zgszkhwx";
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
