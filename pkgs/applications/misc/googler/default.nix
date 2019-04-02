{stdenv, fetchFromGitHub, python}:

stdenv.mkDerivation rec {
  version = "3.8";
  name = "googler-${version}";

  src = fetchFromGitHub {
    owner = "jarun";
    repo = "googler";
    rev = "v${version}";
    sha256 = "0f15rivjdj8r7wwrckcsaxxx129yh41fj4rhz4cbvbsb5f0f2daj";
  };

  propagatedBuildInputs = [ python ];

  buildFlags = [ "disable-self-upgrade" ];
  installFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    mkdir -p $out/share/bash-completion/completions
    cp auto-completion/bash/googler-completion.bash $out/share/bash-completion/completions/googler

    mkdir -p $out/share/zsh/site-functions
    cp auto-completion/zsh/_googler $out/share/zsh/site-functions/
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/jarun/googler;
    description = "Google Search, Google Site Search, Google News from the terminal";
    license = licenses.gpl3;
    maintainers = with maintainers; [ koral ];
    platforms = platforms.unix;
  };
}
