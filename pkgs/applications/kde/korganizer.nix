{
  mkDerivation, lib, kdepimTeam, fetchFromGitHub,
  extra-cmake-modules, kdoctools,
  qtbase, qttools,
  phonon,
  knewstuff,
  akonadi-calendar, akonadi-contacts, akonadi-notes, akonadi-search,
  calendarsupport, eventviews, incidenceeditor, kcalutils, kdepim-apps-libs,
  kholidays, kidentitymanagement, kldap, kmailtransport, kontactinterface,
  kparts, kpimtextedit, pimcommon,
}:

mkDerivation {
  name = "korganizer";
  meta = {
    license = with lib.licenses; [ gpl2 lgpl21 fdl12 ];
    maintainers = kdepimTeam;
  };
  nativeBuildInputs = [ extra-cmake-modules kdoctools ];
  propagatedBuildInputs = [
    qtbase qttools
    phonon
    knewstuff
    akonadi-calendar akonadi-contacts akonadi-notes akonadi-search
    calendarsupport eventviews incidenceeditor kcalutils kdepim-apps-libs
    kholidays kidentitymanagement kldap kmailtransport kontactinterface
    kparts kpimtextedit pimcommon
  ];
  #src = fetchFromGitHub {
  #  owner = "KDE";
  #  repo = "korganizer";
  #  rev = "08438b04e96f9a1310134af08a9e6323b702ab38";
  #  sha256 = "0b4klzsdbf6h6qp64psp3dr90dp8ll4xcxzw0v1j75zc0ms5avyw";
  #};
}
