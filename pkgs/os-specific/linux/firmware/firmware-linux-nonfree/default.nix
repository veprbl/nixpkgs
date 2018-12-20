{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  name = "firmware-linux-nonfree-${version}";
  version = "2018-12-18";

  src = fetchgit {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
    rev = "0f22c8527439eaaf5c3fcf87b31c89445b6fa84d";
    sha256 = "1ja7b5bsv5w0arycxx9rb3fph16xllpnvzbflzq7cziw9aqdcp7i";
  };

  installFlags = [ "DESTDIR=$(out)" ];

  # Firmware blobs do not need fixing and should not be modified
  dontFixup = true;

  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = "0fv0lj52rwcmngavw95n3nmlpc2wmnm769vgzg4f42j4dh206c94";

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
