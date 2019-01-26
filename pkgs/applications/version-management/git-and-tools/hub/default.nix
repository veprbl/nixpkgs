{ stdenv, buildGoPackage, fetchFromGitHub, ronn, ruby, groff, Security, utillinux }:

buildGoPackage rec {
  name = "hub-${version}";
  version = "2.8.3";

  goPackagePath = "github.com/github/hub";

  src = fetchFromGitHub {
    owner = "github";
    repo = "hub";
    rev = "v${version}";
    sha256 = "0vym13c9qx6nr6gd5w842mi1wpzirjn309dd1533hh7919v67sii";
  };

  nativeBuildInputs = [ groff ronn utillinux ];
  buildInputs = [ ruby ] ++
    stdenv.lib.optional stdenv.isDarwin Security;

  postPatch = ''
    mkdir bin
    ln -s ${ronn}/bin/ronn bin/ronn
    patchShebangs .
  '';

  postInstall = ''
    cd go/src/${goPackagePath}
    install -D etc/hub.zsh_completion "$bin/share/zsh/site-functions/_hub"
    install -D etc/hub.bash_completion.sh "$bin/share/bash-completion/completions/hub"
    install -D etc/hub.fish_completion  "$bin/share/fish/vendor_completions.d/hub.fish"

    make man-pages
    cp -vr --parents share/man/man[1-9]/*.[1-9] $bin/
  '';

  meta = with stdenv.lib; {
    description = "Command-line wrapper for git that makes you better at GitHub";

    license = licenses.mit;
    homepage = https://hub.github.com/;
    maintainers = with maintainers; [ the-kenny ];
    platforms = with platforms; unix;
  };
}
