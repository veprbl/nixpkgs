{ stdenv, fetchgit, autoconf, automake, libtool, pkgconfig,
  zeromq2, libbitcoin, libconfig
}:

let version = "512883ed60"; in

stdenv.mkDerivation {
  name = "obelisk-${version}";

  src = fetchgit {
    url = "https://github.com/spesmilo/obelisk.git";
    rev = "512883ed60fe4e90278f526fb99b39d293ab6dd4";
    sha256 = "0y3zyklqzis5d5k1g35sp87mlvpm9h8h1d99vjyphr6x6bpmxni3";
  };

  buildInputs = [ libbitcoin ];
  propagatedBuildInputs = [ zeromq2 libconfig ];
  nativeBuildInputs = [ autoconf automake libtool pkgconfig ];

  preConfigure = "autoreconf -i";

  meta = {
    homepage = https://github.com/spesmilo/obelisk;
    description = "Scalable Bitcoin backend using libbitcoin";
    license = stdenv.lib.licenses.agpl3;
    platforms = stdenv.lib.platforms.linux;
  };
}
