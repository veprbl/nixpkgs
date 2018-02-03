{ stdenv, fetchurl, autoreconfHook }:

stdenv.mkDerivation {
  name = "yara-retdec-1.0";
  src = fetchurl {
    url = "https://github.com/avast-tl/yara/archive/v1.0-retdec.tar.gz";
    sha256 = "0bslms2wj49g57x1h8xhysi6l0n472m5043bml4bmpmcina8n0fb";
  };


  nativeBuildInputs = [ autoreconfHook ];

  dontDisableStatic = true;

  configureFlags = [
    "--disable-shared"
    "--without-crypto"
  ];

  meta = with stdenv.lib; {
    description = "The pattern matching swiss knife for malware researchers";
    homepage    = http://Virustotal.github.io/yara/;
    license     = licenses.asl20;
    platforms   = stdenv.lib.platforms.all;
  };
}
