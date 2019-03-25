{stdenv, fetchurl, which, go-md2man, coreutils}:

stdenv.mkDerivation rec {
  version = "1.4.3";
  name = "brillo-${version}";
  src = fetchurl {
  url = "https://gitlab.com/cameronnemo/brillo/-/archive/v${version}/brillo-v${version}.tar.bz2";
    sha256 = "0wjpw9vn521rwpnlhvczzfzdsdq812vsyl151627qw51zadynvz1";
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
