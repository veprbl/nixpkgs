{ stdenv, fetchFromGitHub
, cmake, pkgconfig
, libva, libpciaccess, intel-gmmlib, libX11
}:

stdenv.mkDerivation rec {
  name = "intel-media-driver-${version}";
  version = "19.0.99"; # not really, git leading up to 19.1

  src = fetchFromGitHub {
    owner  = "intel";
    repo   = "media-driver";
    #rev    = "intel-media-${version}";
    rev = "8773ef5e82e8a151e1bcfef317f7808f319c91c2";
    sha256 = "1i96xmw86pfwmd7qnzs9i1lmi2jqlrqabjrw79jx18y1djzrciiz";
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
