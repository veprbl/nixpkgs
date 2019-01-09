{ stdenv, buildGoPackage, fetchFromGitHub, ruby, groff, Security, utillinux }:

buildGoPackage rec {
  name = "hub-${version}";
  #version = "2.7.0";
  version = "2019-01-08";

  goPackagePath = "github.com/github/hub";

  src = fetchFromGitHub {
    owner = "github";
    repo = "hub";
    #rev = "v${version}";
    rev = "ddf0d825100e1b5b218888ade2fa554336002cae";
    sha256 = "1s5p3kj8yd9686w1dx2ay547k7k5i96bd8rx2cmvrh5yw54smzqg";
  };

  nativeBuildInputs = [ groff ruby utillinux ];
  buildInputs = stdenv.lib.optional stdenv.isDarwin Security;

  postPatch = ''
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
