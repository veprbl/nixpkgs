{ stdenv, pkgs, python3, fetchgit, git }:

with python3.pkgs; buildPythonApplication rec {
  pname = "khal";
  version = "0.9.9999"; # not really

  #src = fetchPypi {
  #  inherit pname version;
  #  sha256 = "03h0j0d3xyqh98x5v2gv63wv3g91hip3vsaxvybsn5iz331d23h4";
  #};
  buildInputs = [ git ];
  src = fetchgit {
    url = "https://github.com/pimutils/${pname}";
    rev = "1bc431f5390b280d1f162131f592cde03028fabb";
    sha256 = "01w7rjp3clvv1lv8vagw28k0kj2q9qaiyf7fjvllzsxy6dx6gcis";
    leaveDotGit = true;
  };

  LC_ALL = "en_US.UTF-8";

  propagatedBuildInputs = [
    atomicwrites
    click
    configobj
    dateutil
    icalendar
    lxml
    pkgs.vdirsyncer
    pytz
    pyxdg
    requests_toolbelt
    tzlocal
    urwid
    pkginfo
    freezegun
  ];
  nativeBuildInputs = [ setuptools_scm pkgs.glibcLocales ];
  checkInputs = [ pytest ];

  postInstall = ''
    install -D misc/__khal $out/share/zsh/site-functions/__khal
  '';

  # One test fails as of 0.9.10 due to the upgrade to icalendar 4.0.3
  doCheck = false;

  checkPhase = ''
    py.test
  '';

  meta = with stdenv.lib; {
    homepage = http://lostpackets.de/khal/;
    description = "CLI calendar application";
    license = licenses.mit;
    maintainers = with maintainers; [ jgeerds gebner ];
  };
}
