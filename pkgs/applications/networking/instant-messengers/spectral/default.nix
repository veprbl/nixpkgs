{ stdenv, fetchgit
, pkgconfig, makeWrapper
, qmake, qttools, qtbase, qtquickcontrols2, qtmultimedia
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
  version = "2019-03-02";

  src = fetchgit {
    url = "https://gitlab.com/b0/spectral.git";
    rev = "6dd33af0ca355d084373fdfbc56e9780a3b88917";
    sha256 = "0bs1dxrzsxvhpyhwq9p1w9aar0iyy4hy77qmj17k9qm7h20n0q9v";
    fetchSubmodules = true;
  };

  # Doesn't seem to work without this, used to be documented in the .pro file.  Dunno.
  # Update: upstream uses this in CI so it's not just us :)
  #qmakeFlags = [ "CONFIG+=qtquickcompiler" "CONFIG+=qml_debug" "CONFIG+=debug" ];

  postInstall = ''
    wrapProgram $out/bin/spectral \
      --set QML2_IMPORT_PATH "${qml2ImportPath}"
  '';

  nativeBuildInputs = [ pkgconfig qmake makeWrapper qttools ];
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
