{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  name = "firmware-linux-nonfree-${version}";
  version = "2019-02-21";

  src = fetchgit {
    url = https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git;
    rev = "54b0a748c8966c93aaa8726402e0b69cb51cd5d2";
    sha256 = "0i8v08w54ib7xdscwb4qqkgkpxzjvvsjp2dndi3zr6k954hb4qwv";
  };

  installFlags = [ "DESTDIR=$(out)" ];

  # Firmware blobs do not need fixing and should not be modified
  dontFixup = true;

  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = "13y8mvv5w11cjnk5zvj6rqz707dmxh85yaf28h9cyybkj3qldq9g";

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
