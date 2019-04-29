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
  version = "2019-04-26";

  src = fetchgit {
    url = "https://gitlab.com/b0/spectral.git";
    rev = "d8c98374e46e7cb08dcbb2703d301ca82282e9e1";
    sha256 = "0pyk69vg0gp2lx4vhicx4s4bx4lb1bngniavgcn6hs1n6qby9ic0";
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
