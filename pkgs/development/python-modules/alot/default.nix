{ stdenv, lib, buildPythonPackage, fetchFromGitHub, isPy3k
, notmuch, urwid, urwidtrees, twisted, python_magic, configobj, mock, file, gpgme
, service-identity
, gnupg ? null, sphinx, awk ? null, procps ? null, future ? null
, withManpage ? false }:


buildPythonPackage rec {
  pname = "alot";
  outputs = [ "out" ] ++ lib.optional withManpage "man";

  disabled = !isPy3k;

  version = "2018-10-01";

  src = fetchFromGitHub {
    owner = "pazz";
    repo = "alot";
    rev = "41197b766f5223c1d3f02594c9324b67c14c56ae";
    sha256 = "0ynwpp8hkhhl3iydzviadi2p5iwcmybd9z5c7jpf3264hhnyj0yd";
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

  # some twisted tests need the network (test_env_set... )
  doCheck = false;
  postBuild = lib.optionalString withManpage "make -C docs man";

  checkInputs =  [ awk future mock gnupg procps ];

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
