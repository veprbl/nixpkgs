{ stdenv, fetchgit, fetchurl, pkgconfig, vpnc, openssl ? null, gnutls ? null, gmp, libxml2, stoken, zlib, lz4, libtasn1, pcsclite }:

assert (openssl != null) == (gnutls == null);

stdenv.mkDerivation rec {
  pname = "openconnect";
  version = "8.01";

  src = fetchurl {
    urls = [
      "ftp://ftp.infradead.org/pub/openconnect/${pname}-${version}.tar.gz"
    ];
    sha256 = "1z96ssf2v9xflwiry73pahmx79zap10vpfkzv1s786n8k57qm1j8";
  };

  outputs = [ "out" "dev" ];

  configureFlags = [
    "--with-vpnc-script=${vpnc}/etc/vpnc/vpnc-script"
    "--disable-nls"
    "--without-openssl-version-check"
  ];

  nativeBuildInputs = [ pkgconfig ];
  propagatedBuildInputs = [ vpnc openssl gnutls gmp libxml2 stoken zlib lz4 libtasn1 pcsclite ];

  meta = {
    description = "VPN Client for Cisco's AnyConnect SSL VPN";
    homepage = http://www.infradead.org/openconnect/;
    license = stdenv.lib.licenses.lgpl21;
    maintainers = with stdenv.lib.maintainers; [ pradeepchhetri ];
    platforms = stdenv.lib.platforms.linux;
  };
}
