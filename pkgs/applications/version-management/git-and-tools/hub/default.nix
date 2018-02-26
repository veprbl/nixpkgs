{ stdenv, fetchgit, go, Security }:

stdenv.mkDerivation rec {
  name = "hub-${version}";
  version = "2018-02-22";

  src = fetchgit {
    url = https://github.com/github/hub.git;
    #rev = "refs/tags/v${version}";
    #sha256 = "195ckp1idz2azv0mm1q258yjz2n51sia9xdcjnqlprmq9aig5ldh";
    rev = "dbe8a5d7a0310725489003671c44a074074d3fc4";
    sha256 = "00iv91f32lgj18a8xhjnz06jwzljgmh51ppw1nspkgy1866239d9";
  };


  buildInputs = [ go ] ++ stdenv.lib.optional stdenv.isDarwin Security;

  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  buildPhase = ''
    patchShebangs .
    sh script/build
  '';

  installPhase = ''
    mkdir -p "$out/bin"
    cp bin/hub "$out/bin/"

    #  mkdir -p "$out/share/man/man1"
    #  cp "man/hub.1" "$out/share/man/man1/"

    mkdir -p "$out/share/zsh/site-functions"
    cp "etc/hub.zsh_completion" "$out/share/zsh/site-functions/_hub"

    mkdir -p "$out/etc/bash_completion.d"
    cp "etc/hub.bash_completion.sh" "$out/etc/bash_completion.d/"

    # Should we also install provided git-hooks?
    # ?
  '';

  meta = with stdenv.lib; {
    description = "Command-line wrapper for git that makes you better at GitHub";

    license = licenses.mit;
    homepage = https://hub.github.com/;
    maintainers = with maintainers; [ the-kenny ];
    platforms = with platforms; unix;
  };
}
