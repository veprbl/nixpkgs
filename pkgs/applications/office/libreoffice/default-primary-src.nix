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
    sha256 = "1phsdcyvjm289ca7y72bkabn4b2p72d78np9yp6gv0n5zcd5il47";
  };
}
