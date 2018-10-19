{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "laptop-mode-tools-${version}";
  version = "1.72.2";

  src = fetchFromGitHub {
    owner = "rickysarraf";
    repo = "laptop-mode-tools";
    rev = version;
    sha256 = "1pl0rh1bh23ji5r60nvra26ns3z5dfbjj1l9lhzf7hsmpydrgznd";
  };

  installPhase = ''
    MAN_D=/share/man \
    ULIB_D=/lib \
    DESTDIR=$out \
    INIT_D="none" \
    INSTALL=install \
    SYSTEMD=yes \
    ./install.sh
  '';
}
