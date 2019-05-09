{ fetchurl, stdenv, fetchgit
, pkgconfig, gnupg
, xapian, gmime, talloc, zlib
, doxygen, perl
, pythonPackages
, bash-completion
, emacs
, ruby
, which, dtach, openssl, bash, gdb, man
}:

with stdenv.lib;

# notmuch no longer supports gmime < 3.0, let's be sure nothing tries to do so
assert (versionAtLeast gmime.version "3.0");

stdenv.mkDerivation rec {
  version = "0.28.4"; # not really, git
  name = "notmuch-${version}";

  passthru = {
    pythonSourceRoot = "${name}/bindings/python";
    #pythonSourceRoot = "${src}/bindings/python"; # lol
    inherit version;
  };

  src = fetchgit {
    inherit name;
    url = git://git.notmuchmail.org/git/notmuch;
    rev = "325a92422737f16377307dbd584158d3ee8cdb51";
    sha256 = "0ky1v3dqgjl6fphph6mhn0bd6j0x8dwv6fa6zg37cwl9rqfda2m6";
  };
  #src = fetchurl {
  #  url = "https://notmuchmail.org/releases/${name}.tar.gz";
  #  sha256 = "1v0ff6qqwj42p3n6qw30czzqi52nvgf3dn05vd7a03g39a5js8af";
  #};

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [
    gnupg # undefined dependencies
    xapian gmime talloc zlib  # dependencies described in INSTALL
    doxygen perl  # (optional) api docs
    pythonPackages.sphinx pythonPackages.python  # (optional) documentation -> doc/INSTALL
    bash-completion  # (optional) dependency to install bash completion
    emacs  # (optional) to byte compile emacs code, also needed for tests
    ruby  # (optional) ruby bindings
  ];

  # This is actually not 0.28.4, but from git--
  # latest git is broken for me, but can't drop
  # to 0.28.4 without having to re-index (again)
  # so instead cherry-pick the single change
  # that makes 0.28.4 not 0.28.3 :)
  patches = [ ./fix-empty-write-0.28.4.patch ];

  postPatch = ''
    patchShebangs configure
    patchShebangs test/

    for src in \
      util/crypto.c \
      notmuch-config.c
    do
      substituteInPlace "$src" \
        --replace \"gpg\" \"${gnupg}/bin/gpg\"
    done

    substituteInPlace lib/Makefile.local \
      --replace '-install_name $(libdir)' "-install_name $out/lib"
  '';

  configureFlags = [
    "--without-emacs"
    #"--without-docs"
    #"--without-api-docs"
    "--zshcompletiondir=${placeholder "out"}/share/zsh/site-functions"
  ];

  # Notmuch doesn't use autoconf and consequently doesn't tag --bindir and
  # friends
  setOutputFlags = false;
  enableParallelBuilding = true;
  makeFlags = [ "V=1" ];

  preCheck = let
    test-database = fetchurl {
      url = "https://notmuchmail.org/releases/test-databases/database-v1.tar.xz";
      sha256 = "1lk91s00y4qy4pjh8638b5lfkgwyl282g1m27srsf7qfn58y16a2";
    };
  in ''
    ln -s ${test-database} test/test-databases/database-v1.tar.xz
  '';
  doCheck = !stdenv.hostPlatform.isDarwin && (versionAtLeast gmime.version "3.0");
  checkTarget = "test";
  checkInputs = [
    which dtach openssl bash
    gdb man
  ];

  installTargets = [ "install" "install-man" ];

  dontGzipMan = true; # already compressed

  meta = {
    description = "Mail indexer";
    homepage    = https://notmuchmail.org/;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ flokli garbas the-kenny ];
    platforms   = platforms.unix;
  };
}
