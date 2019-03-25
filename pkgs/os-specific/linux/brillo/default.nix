{stdenv, fetchFromGitLab , which, go-md2man, coreutils}:

stdenv.mkDerivation rec {
  version = "1.4.3";
  name = "brillo-${version}";
  src = fetchFromGitLab {
    owner= "cameronnemo";
    repo= "brillo";
    rev= "v${version}";
    sha256 = "1syv3iav7bwr84x9frz1qd6qmgp8ldbjs4gl3r94nhllkai9spaq";
  };
  makeFlags = [ "PREFIX=" "DESTDIR=$(out)"];
  nativeBuildInputs = [go-md2man which];
  buildFlags = [ "dist" ];
  installTargets = "install-dist";

  postPatch = ''
    substituteInPlace contrib/90-brillo.rules --replace /bin/ ${coreutils}/bin/
  '';

  meta = with stdenv.lib; {
    description = "Backlight and Keyboard LED control tool";
    homepage = https://gitlab.com/cameronnemo/brillo;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.alexarice ];
  };
}
