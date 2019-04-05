{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  name = "firmware-linux-nonfree-${version}";
  version = "2019-03-12";

  src = fetchgit {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
    rev = "20190312";
    sha256 = "1wk8l75rg7idvsyli29a1fii4xwz3vnm8d65fjw8d3azihdrhbyy";
  };

  installFlags = [ "DESTDIR=${placeholder "out"}" ];

  # Firmware blobs do not need fixing and should not be modified
  dontFixup = true;

  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = "19wn81qhd7cwpr6s291mhzgk039in972r6ssm0z954wklz93wqyy";

  meta = with stdenv.lib; {
    description = "Binary firmware collection packaged by kernel.org";
    homepage = http://packages.debian.org/sid/firmware-linux-nonfree;
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
    maintainers = with maintainers; [ fpletz ];
    priority = 6; # give precedence to kernel firmware
  };

  passthru = { inherit version; };
}
