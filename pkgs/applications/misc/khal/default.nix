{ stdenv, pkgs, python3, fetchgit, git }:

with python3.pkgs; buildPythonApplication rec {
  pname = "khal";
  version = "0.9.9999"; # not really

  #src = fetchPypi {
  #  inherit pname version;
  #  sha256 = "03h0j0d3xyqh98x5v2gv63wv3g91hip3vsaxvybsn5iz331d23h4";
  #};
  src = fetchgit {
    url = "https://github.com/pimutils/${pname}";
    rev = "46b4b3e2c382371a96414c8406f8b08a75e08c34";
    sha256 = "09kgaxr3j5vj8k4cw97x3cjb6qgh3dvyix649wzh71cp41awh418";
    leaveDotGit = true;
  };

  LC_ALL = "C.UTF-8";

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
  nativeBuildInputs = [ setuptools_scm pkgs.glibcLocales git ];
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
