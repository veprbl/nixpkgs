{ stdenv, fetchgit
, pkgconfig, makeWrapper
, qmake, qtbase, qtquickcontrols2, qtmultimedia
, libpulseaudio
# Not mentioned but seems needed
, qtgraphicaleffects
, qtdeclarative
}:

let
  # Following "borrowed" from yubikey-manager-qt
  qmlPath = qmlLib: "${qmlLib}/${qtbase.qtQmlPrefix}";

  inherit (stdenv) lib;

  qml2ImportPath = lib.concatMapStringsSep ":" qmlPath [
    qtbase.bin qtdeclarative.bin qtquickcontrols2.bin qtgraphicaleffects qtmultimedia
  ];

in stdenv.mkDerivation rec {
  pname = "spectral";
  version = "2019-04-07";

  src = fetchgit {
    url = "https://gitlab.com/b0/spectral.git";
    rev = "fae602e7dfd05e00c7dbe376f5b5c2aa24f904c3";
    sha256 = "1x9hjgjncz7iw49z59y4yj1hz3q1i3n64gyhcj8pzd9k6smz8s2a";
    fetchSubmodules = true;
  };

  qmakeFlags = [ "CONFIG+=qtquickcompiler" "BUNDLE_FONT=true" ];

  postInstall = ''
    wrapProgram $out/bin/spectral \
      --set QML2_IMPORT_PATH "${qml2ImportPath}"
  '';

  nativeBuildInputs = [ pkgconfig qmake makeWrapper ];
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
