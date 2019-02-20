{ fetchurl }:

rec {
  major = "6";
  minor = "2";
  patch = "0";
  tweak = "3";

  subdir = "${major}.${minor}.${patch}";

  version = "${subdir}${if tweak == "" then "" else "."}${tweak}";

  src = fetchurl {
    url = "https://download.documentfoundation.org/libreoffice/src/${subdir}/libreoffice-${version}.tar.xz";
    sha256 = "1zip7clhh3bp9smlxx1y5zpnwhaa6p0xlxg7k5d644q8gqbyk3v4";
  };
}
