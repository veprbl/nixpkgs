{
  mkDerivation, lib, kdepimTeam, fetchFromGitHub,
  extra-cmake-modules, kdoctools,
  akonadi, akonadi-contacts, calendarsupport, kcalcore, kcompletion,
  kconfigwidgets, kcontacts, kdbusaddons, kitemmodels, kpimtextedit, libkdepim,
  ktextwidgets, kxmlgui, messagelib, qtbase, akonadi-search, xapian
}:

mkDerivation {
  name = "akonadiconsole";
  meta = {
    license = with lib.licenses; [ gpl2 lgpl21 fdl12 ];
    maintainers = kdepimTeam;
  };
  nativeBuildInputs = [ extra-cmake-modules kdoctools ];
  buildInputs = [
    akonadi akonadi-contacts calendarsupport kcalcore kcompletion kconfigwidgets
    kcontacts kdbusaddons kitemmodels kpimtextedit ktextwidgets kxmlgui
    messagelib qtbase libkdepim akonadi-search xapian
  ];

  src = fetchFromGitHub {
    owner = "KDE";
    repo = "akonadiconsole";
    rev = "2f0f78c9d86e4f6c1cf71e9742d078e51c03a43f";
    sha256 = "1x7nv3bxghcpjv5rrw5mjbrpg24g3k0w3g1lal6ksxj549p0lh2h";
  };
}
