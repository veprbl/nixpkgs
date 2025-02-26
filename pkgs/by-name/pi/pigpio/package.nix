{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "pigpio";
  version = "79";

  src = fetchFromGitHub {
    owner = "joan2937";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-Z+SwUlBbtWtnbjTe0IghR3gIKS43ZziN0amYtmXy7HE=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = with lib; {
    description = "A C library for the Raspberry which allows control of the General Purpose Input Outputs (GPIO)";
    license = licenses.unlicense;
    homepage = "http://abyz.me.uk/rpi/pigpio/index.html";
    platforms = platforms.linux;
    maintainers = with maintainers; [ veprbl ];
  };
}
