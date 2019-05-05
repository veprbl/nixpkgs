{stdenv, fetchFromGitLab , which, go-md2man, coreutils, substituteAll }:

stdenv.mkDerivation rec {
  version = "1.4.8";
  pname = "brillo";
  src = fetchFromGitLab {
    owner= "cameronnemo";
    repo= "brillo";
    rev= "v${version}";
    sha256 = "0wxvg541caiwm3bjwbmk7xcng7jd9xsiga2agxwp7gpkrlp74j9f";
  };
  makeFlags = [ "PREFIX=$(out)" "AADIR=$(out)/etc/apparmor.d"];
  nativeBuildInputs = [go-md2man which];
  buildFlags = [ "dist" ];
  installTargets = [ "install-dist" "install.apparmor" ];
  patches = [
  (substituteAll {
    src = ./udev-rule.patch;
    inherit coreutils;
  }) ];

  meta = with stdenv.lib; {
    description = "Backlight and Keyboard LED control tool";
    homepage = https://gitlab.com/cameronnemo/brillo;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.alexarice ];
  };
}
