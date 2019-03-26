{ stdenv, pkgs, python3, fetchgit, git }:

with python3.pkgs; buildPythonApplication rec {
  pname = "khal";
  version = "0.10.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1p49f3g25x900vk32spjbr2aipj12kcbhayny2vwhdpkjlv6k396";
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
    maintainers = with maintainers; [ gebner ];
  };
}
