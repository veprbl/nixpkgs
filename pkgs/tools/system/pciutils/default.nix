{ stdenv, fetchurl, fetchFromGitHub, pkgconfig, zlib, kmod, which }:

stdenv.mkDerivation rec {
  pname = "pciutils";
  #version = "3.6.2"; # with release-date database
  version = "2019-02-21";

  #src = fetchurl {
  #  url = "mirror://kernel/software/utils/pciutils/${pname}-${version}.tar.xz";
  #  sha256 = "1wwkpglvvr1sdj2gxz9khq507y02c4px48njy25divzdhv4jwifv";
  #};
  src = fetchFromGitHub {
    owner = "pciutils";
    repo = "pciutils";
    rev = "33226851677b92fffd186002d74a1a515fb49413";
    sha256 = "0z4f5y7mfkar2adblr32csd19vcg0wlbhap4bcsrbg342n7866ky";
  };

  nativeBuildInputs = [ pkgconfig which ];
  buildInputs = [ zlib kmod ];

  makeFlags = [
    "SHARED=yes"
    "PREFIX=${placeholder "out"}"
    "STRIP="
    "HOST=${stdenv.hostPlatform.system}"
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    "DNS=yes"
  ];

  installTargets = [ "install" "install-lib" ];

  # Get rid of update-pciids as it won't work.
  postInstall = "rm $out/sbin/update-pciids $out/man/man8/update-pciids.8";

  meta = with stdenv.lib; {
    homepage = http://mj.ucw.cz/pciutils.html;
    description = "A collection of programs for inspecting and manipulating configuration of PCI devices";
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
    maintainers = [ maintainers.vcunat ]; # not really, but someone should watch it
  };
}
