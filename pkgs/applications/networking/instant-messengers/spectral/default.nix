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
  version = "2019-04-29";

  src = fetchgit {
    url = "https://gitlab.com/b0/spectral.git";
    rev = "7458ebf59accaf5b95aa3d06f2f5a6776bcf8edf";
    sha256 = "1saw5jcvbqcyhnn3lkh7zrp8lbvcbaiqjdrarlqa5vcf9nnskcj8";
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
