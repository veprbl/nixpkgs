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
  #version = "603";
  version = "2019-05-02";

  src = fetchgit {
    url = "https://gitlab.com/b0/spectral.git";
    #rev = "refs/tags/${version}";
    rev = "ce688e97568b8dad9eac63e14a85324009bfd1ae";
    sha256 = "0qcya2j119a284mg8anhpvb6rjvwkf1h9f1i25gyr7z3sasknfgi";
    fetchSubmodules = true;
  };

  qmakeFlags = [ "CONFIG+=qtquickcompiler" ];

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
