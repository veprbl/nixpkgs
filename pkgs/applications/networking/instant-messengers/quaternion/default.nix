{ mkDerivation, lib, fetchgit, qtbase, qtquickcontrols, cmake }:

mkDerivation rec {
  name = "quaternion-git-${version}";
  version = "2017-08-30";

  # quaternion and tensor share the same libqmatrixclient library as a git submodule
  #
  # As all 3 projects are in very early stages, we simply load the submodule.
  #
  # At some point in the future, we should separate out libqmatrixclient into its own
  # derivation.

  src = fetchgit {
    url             = "https://github.com/QMatrixClient/Quaternion.git";
    rev             = "1cc1d4adba97551dbdc32e753e00bdbf13e25816";
    sha256          = "1qxcvgmg0dzql4zd0fnfqf0kkzscay2b4gszf2lsrxmdqn158shj";
    fetchSubmodules = true;
  };

  buildInputs = [ qtbase qtquickcontrols ];
  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-Wno-dev"
  ];

  postInstall = ''
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
