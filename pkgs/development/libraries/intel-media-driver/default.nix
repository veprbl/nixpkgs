{ stdenv, fetchFromGitHub
, cmake, pkgconfig
, libva, libpciaccess, intel-gmmlib, libX11
}:

stdenv.mkDerivation rec {
  name = "intel-media-driver-${version}";
  #version = "18.3.0";
  version = "2018-12-15";

  src = fetchFromGitHub {
    owner  = "intel";
    repo   = "media-driver";
#    rev    = "intel-media-${version}";
    rev = "60229409b85b2fad42558f42d2b7648cd1dd2703";
    sha256 = "1ad3g9v4f8kz05yck6q76vaz24cm2xfn9g8yf82zlqmc6af2nqy4";
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
