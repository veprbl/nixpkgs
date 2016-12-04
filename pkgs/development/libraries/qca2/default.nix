{ stdenv, fetchurl, cmake, pkgconfig, qt, Security }:

stdenv.mkDerivation rec {
  name = "qca-2.1.1";

  src = fetchurl {
    url = "http://download.kde.org/stable/qca/2.1.1/src/qca-2.1.1.tar.xz";
    sha256 = "10z9icq28fww4qbzwra8d9z55ywbv74qk68nhiqfrydm21wkxplm";
  };

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [ qt ]
    ++ stdenv.lib.optional stdenv.isDarwin Security;

  enableParallelBuilding = true;

  patches = [ ./libressl.patch ] ++ stdenv.lib.optionals (stdenv.isDarwin) [
    (fetchurl {
      url = "https://github.com/KDE/qca/commit/f223ce03d4b94ffbb093fc8be5adf8d968f54434.diff";
      sha256 = "1dc2yn6zmq44n9i220jbcp6dpvdwilrrgimq6103p33505di1vvm";
    })
    (fetchurl {
      url = "https://github.com/KDE/qca/commit/9e4bf795434304bce32626fe0f6887c10fec0824.diff";
      sha256 = "056345jcifma70b4s9pfmbncqb72nqkxqn1kgq60jmcz5ifmfkjz";
    })
  ];

  meta = with stdenv.lib; {
    description = "Qt Cryptographic Architecture";
    license = "LGPL";
    homepage = http://delta.affinix.com/qca;
    maintainers = [ maintainers.sander maintainers.urkud ];
    platforms = with platforms; [linux darwin];
  };
}
