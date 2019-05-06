{ mkDerivation, fetchurl, lib
, extra-cmake-modules, kdoctools, wrapGAppsHook
, kconfig, kcrash, kinit, kpmcore
, eject, libatasmart , utillinux, makeWrapper, qtbase
}:

let
  pname = "partitionmanager";
in mkDerivation rec {
  name = "${pname}-${version}";
  version = "4.0.0";

  src = fetchurl {
    url = "mirror://kde/stable/${pname}/${version}/src/${name}.tar.xz";
    sha256 = "1q8kqi05qv932spln8bh7n739ivq6pra2pgz67zl2dmdknpysrvr";
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [ extra-cmake-modules kdoctools wrapGAppsHook makeWrapper ];

  # refer to kpmcore for the use of eject
  buildInputs = [ eject libatasmart utillinux ];
  propagatedBuildInputs = [ kconfig kcrash kinit kpmcore ];

  postInstall = ''
    wrapProgram "$out/bin/partitionmanager" --prefix QT_PLUGIN_PATH : "${kpmcore}/lib/qt-5.${lib.versions.minor qtbase.version}/plugins"
  '';

  meta = with lib; {
    description = "KDE Partition Manager";
    license = licenses.gpl2;
    homepage = https://www.kde.org/applications/system/kdepartitionmanager/;
    maintainers = with maintainers; [ peterhoeg ma27 ];
  };
}
