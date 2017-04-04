{stdenv, fetchurl, cryptsetup, dmraid, lvm2, mdadm, kexectools}:

stdenv.mkDerivation rec {
  name = "dracut-${version}";
  version = "044";

  src = fetchurl {
    url = "http://www.kernel.org/pub/linux/utils/boot/dracut/${name}.tar.xz";
    sha256 = "01dgan37i77cp60fk1g0v362qqy4w7nz571vdkhgvs9006dprfc4";
  };

  buildInputs = [ cryptsetup dmraid lvm2 mdadm kexectools ];

  preConfigure = ''
    patchShebangs configure
  '';

  meta = with stdenv.lib; {
    description = "Generic, modular, cross-distribution initramfs generation tool";
    homepage = https://dracut.wiki.kernel.org/;
    license = licenses.isc;
    maintainers = with maintainers; [mic92];
    platforms = with platforms; linux;
  };
}
