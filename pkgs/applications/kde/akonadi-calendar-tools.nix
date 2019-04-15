{
  mkDerivation, lib, kdepimTeam,
  extra-cmake-modules, kdoctools,
  akonadi, akonadi-contacts, akonadi-calendar, libkdepim, calendarsupport, kcalcore, kcalutils, kcontacts,
  kidentitymanagement, kio, kmailtransport,
}:

mkDerivation {
  name = "akonadi-calendar-tools";
  meta = {
    license = with lib.licenses; [ gpl2 lgpl21 ];
    maintainers = kdepimTeam;
  };
  nativeBuildInputs = [ extra-cmake-modules kdoctools ];
  propagatedBuildInputs = [
    akonadi akonadi-contacts akonadi-calendar libkdepim kcalcore kcalutils kcontacts kidentitymanagement
    kio kmailtransport calendarsupport
  ];
  outputs = [ "out" "dev" ];
}
