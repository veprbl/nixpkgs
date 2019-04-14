{
  mkDerivation, lib,
  fetchurl, fetchFromGitHub,
  extra-cmake-modules,
  qtbase, boost,
  akonadi-calendar, akonadi-notes, akonadi-search, kidentitymanagement, kontactinterface, kldap,
  krunner, kwallet
}:

mkDerivation rec {
  pname = "zanshin";
  version = "0.5.0";

  #src = fetchurl {
  #  url = "https://download.kde.org/stable/${pname}/${pname}-${version}.tar.xz";
  #  sha256 = "0kyv7bmj9zv69jybdbp3n1ckmlq326bdq9rhzzcz71hifj4c1087";
  #};
  src = fetchFromGitHub {
    owner = "KDE";
    repo = pname;
    rev = "43302c2eea1cc234596ac6d52c452cbba2eee377";
    sha256 = "09ibbx747mfnk5pgzjl6i8yi2li0xppd9vfqzkrml8vpr6jqwbvy";
  };

  nativeBuildInputs = [
    extra-cmake-modules
  ];

  buildInputs = [
    qtbase boost
    akonadi-calendar akonadi-notes akonadi-search kidentitymanagement kontactinterface kldap
    krunner kwallet
  ];

  meta = with lib; {
    description = "A powerful yet simple application to manage your day to day actions, getting your mind like water";
    homepage = https://zanshin.kde.org/;
    maintainers = with maintainers; [ zraexy ];
    platforms = platforms.linux;
    license = licenses.gpl2Plus;
  };
}
