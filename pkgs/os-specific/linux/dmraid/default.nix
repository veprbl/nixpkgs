{ stdenv, fetchurl, fetchpatch, devicemapper }:

stdenv.mkDerivation rec {
  name = "dmraid-1.0.0.rc16-3";

  src = fetchurl {
    url = "http://people.redhat.com/heinzm/sw/dmraid/src/${name}.tar.bz2";
    sha256 = "1n7vsqvh7y6yvil682q129d21yhb0cmvd5fvsbkza7ypd78inhlk";
  };

  patches = [
    ./hardening-format.patch
    (fetchpatch {
      url = "https://raw.githubusercontent.com/MicrochipTech/buildroot/master/package/dmraid/0001-fix-compilation-under-musl.patch";
      sha256 = "0cvnrf3mzapi0lvz6giq0rd3hk8ns1ywac5n7ng2zvsl6847bw6m";
    })
  ];

  preConfigure = "cd */*/";

  buildInputs = [ devicemapper ];

  meta = {
    description = "Old-style RAID configuration utility";
    longDescription = ''
      Old RAID configuration utility (still under development, though).
      It is fully compatible with modern kernels and mdadm recognizes
      its volumes. May be needed for rescuing an older system or nuking
      the metadata when reformatting.
    '';
    maintainers = [ stdenv.lib.maintainers.raskin ];
    platforms = stdenv.lib.platforms.linux;
  };
}
