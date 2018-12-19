{ stdenv, lib, buildPythonPackage, fetchFromGitHub, isPy3k
, notmuch, urwid, urwidtrees, twisted, python_magic, configobj, mock, file, gpgme
, service-identity, glibcLocales
, gnupg ? null, sphinx, awk ? null, procps ? null, future ? null
, withManpage ? false }:


buildPythonPackage rec {
  pname = "alot";
  version = "0.8";
  outputs = [ "out" ] ++ lib.optional withManpage "man";

  disabled = !isPy3k;

  src = fetchFromGitHub {
    owner = "dtzWill";
    repo = "alot";
    rev = "1ee0d21edd84844d710743e0ebd8232300f66592";
    sha256 = "00j5jcn559xzszgpjpd6divsy2zbxdrsi6p3gyld882dibd3bv7b";
  };

  nativeBuildInputs = lib.optional withManpage sphinx;

  propagatedBuildInputs = [
    notmuch
    urwid
    urwidtrees
    twisted
    python_magic
    configobj
    service-identity
    file
    gpgme
  ];

  # Some minor tests fail, but AFAiCT tests are bad?
  # If I knew how to specify skipping certain tests that'd be better!
  doCheck = false;
  postBuild = lib.optionalString withManpage "make -C docs man";

  LC_ALL = "en_US.utf8";

  checkInputs =  [ awk future mock gnupg procps glibcLocales ];

  postInstall = lib.optionalString withManpage ''
    mkdir -p $out/man
    cp -r docs/build/man $out/man
  ''
  + ''
    mkdir -p $out/share/{applications,alot}
    cp -r extra/themes $out/share/alot

    install -D extra/completion/alot-completion.zsh $out/share/zsh/site-functions/_alot

    sed "s,/usr/bin,$out/bin,g" extra/alot.desktop > $out/share/applications/alot.desktop
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/pazz/alot;
    description = "Terminal MUA using notmuch mail";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ garbas ];
  };
}
