{ stdenv, fetchFromGitHub, coreutils }:

stdenv.mkDerivation rec {
  name = "laptop-mode-tools-${version}";
  version = "1.72.2";

  src = fetchFromGitHub {
    owner = "rickysarraf";
    repo = "laptop-mode-tools";
    rev = version;
    sha256 = "1pl0rh1bh23ji5r60nvra26ns3z5dfbjj1l9lhzf7hsmpydrgznd";
  };

  postPatch = ''
    substituteInPlace install.sh \
      --replace DESTDIR/usr DESTDIR
  '';

  installPhase = ''
    MAN_D=/share/man \
    ULIB_D=/lib \
    DESTDIR=$out \
    INIT_D="none" \
    INSTALL=install \
    SYSTEMD=yes \
    ./install.sh
  '';

  preFixup = ''
    substituteInPlace $out/lib/udev/rules.d/99-laptop-mode.rules \
      --replace lmt-udev $out/lib/udev/lmt-udev

    substituteInPlace $out/lib/systemd/system/lmt-poll.service \
      --replace /lib/udev/lmt-udev $out/lib/udev/lmt-udev

    substituteInPlace $out/lib/systemd/system/laptop-mode.service \
      --replace /bin/rm ${coreutils}/bin/rm \
      --replace /usr/sbin/laptop-mode-tools $out/bin/laptop-mode-tools
  '';
}
