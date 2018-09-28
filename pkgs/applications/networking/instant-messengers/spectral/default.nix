{ stdenv, fetchgit
, pkgconfig
, qmake, qtbase, qtquickcontrols2, qtmultimedia
, libpulseaudio
# Not mentioned but seems needed
, qtgraphicaleffects
# Unsure but needed by similar
, qtdeclarative, qtsvg
}:

stdenv.mkDerivation rec {
  name = "spectral-${version}";
  version = "2018-09-28";

  src = fetchgit {
    url = "https://gitlab.com/b0/spectral.git";
    rev = "01196e8b50fffbf23799b61672eff2b97a6f1120";
    sha256 = "10xgxpjcgzmpk0qny2syw2j3844b9chl64gjjsni2gknlbl3arz8";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkgconfig qmake ];
  buildInputs = [ qtbase qtquickcontrols2 qtmultimedia qtgraphicaleffects qtdeclarative qtsvg ]
    ++ stdenv.lib.optional stdenv.hostPlatform.isLinux libpulseaudio;

  meta = with stdenv.lib; {
    description = "A glossy client for Matrix, written in QtQuick Controls 2 and C++";
    homepage = https://gitlab.com/b0/spectral;
    license = licenses.gpl3;
    platforms = with platforms; linux ++ darwin;
    maintainers = with maintainers; [ dtzWill ];
  };
}
