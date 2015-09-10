{ stdenv, fetchFromGitHub, scons, pkgconfig, openssl, protobuf, boost, zlib}:

stdenv.mkDerivation rec {
  name = "rippled-${version}";
  version = "0.29.0-hf1";

  src = fetchFromGitHub {
    owner = "ripple";
    repo = "rippled";
    rev = version;
    sha256 = "057yz1834wa1w5xi9q4s2pmc9fj5xz1kvkwc59d2g20amgn37f5m";
  };

  postPatch = ''
    sed -i -e "s@ENV = dict.*@ENV = os.environ@g" SConstruct
  '';

  buildInputs = [ scons pkgconfig openssl protobuf boost zlib ];

  buildPhase = "scons";

  installPhase = ''
    mkdir -p $out/bin
    cp build/rippled $out/bin/
  '';

  meta = with stdenv.lib; {
    description = "Ripple P2P payment network reference server";
    homepage = https://ripple.com;
    maintainers = with maintainers; [ emery offline ];
    license = licenses.isc;
    platforms = [ "x86_64-linux" ];
  };
}
