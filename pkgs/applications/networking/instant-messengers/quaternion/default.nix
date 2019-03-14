{ stdenv, lib, fetchFromGitHub, qtbase, qtquickcontrols, cmake
, qttools, libqmatrixclient }:

stdenv.mkDerivation rec {
  name = "quaternion-${version}";
  version = "0.0.9.4-beta2";

  src = fetchFromGitHub {
    owner  = "QMatrixClient";
    repo   = "Quaternion";
    rev    = version;
    sha256 = "1qmsfhxfkf2mxhfxk6p54wlyds2sk35z3gn5f7pxilwbr3wwv7d3";
  };

  buildInputs = [ qtbase qtquickcontrols qttools libqmatrixclient ];

  nativeBuildInputs = [ cmake ];

  postInstall = if stdenv.isDarwin then ''
    mkdir -p $out/Applications
    mv $out/bin/quaternion.app $out/Applications
    rmdir $out/bin || :
  '' else ''
    substituteInPlace $out/share/applications/quaternion.desktop \
      --replace 'Exec=quaternion' "Exec=$out/bin/quaternion"
  '';

  meta = with lib; {
    description = "Cross-platform desktop IM client for the Matrix protocol";
    homepage    = https://matrix.org/docs/projects/client/quaternion.html;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ peterhoeg ];
    inherit (qtbase.meta) platforms;
    inherit version;
  };
}
