{ stdenv, fetchFromGitHub
, cmake, pkgconfig
, libva, libpciaccess, intel-gmmlib, libX11
}:

stdenv.mkDerivation rec {
  name = "intel-media-driver-${version}";
  version = "19.0.99"; # not really, 1";

  src = fetchFromGitHub {
    owner  = "intel";
    repo   = "media-driver";
    #rev    = "intel-media-${version}";
    rev    = "42f6f2310b4b8c47580717b22f13d94b211e0598";
    sha256 = "15padfa2y0ssbhlzqj2vy7fzcvmbpcv7s7r969rs3ms4bnhvbhmp";
  };

  cmakeFlags = [
    "-DINSTALL_DRIVER_SYSCONF=OFF"
    "-DLIBVA_DRIVERS_PATH=${placeholder "out"}/lib/dri"
  ];

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ libva libpciaccess intel-gmmlib libX11 ];

  meta = with stdenv.lib; {
    homepage = https://github.com/intel/media-driver;
    license = with licenses; [ bsd3 mit ];
    description = "Intel Media Driver for VAAPI — Broadwell+ iGPUs";
    platforms = platforms.linux;
    maintainers = with maintainers; [ jfrankenau ];
  };
}
