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
  version = "2018-10-02";

  src = fetchgit {
    url = "https://gitlab.com/b0/spectral.git";
    rev = "a62792fa3bea17ae73e6fd4ce3eb6389bf9da566";
    sha256 = "1rpjashn837hpb4qvw3bbhnw8w1q26mwz7qk933b8hn3ck85avmh";
    fetchSubmodules = true;
  };

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
