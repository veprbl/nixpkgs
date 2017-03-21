{ stdenv, fetchurl, rustPlatform, cargo, darwin, perl }:

rustPlatform.buildRustPackage rec {
  name = "pijul-${version}";
  version = "0.3";

  src = fetchurl {
    url = "https://pijul.org/releases/pijul-0.3.tar.gz";
    sha256 = "2c7b354b4ab142ac50a85d70c80949ff864377b37727b862d103d3407e2c7818";
  };
  depsSha256 = "";

  buildInputs = [ cargo perl ]
    ++ stdenv.lib.optional stdenv.isDarwin (with darwin.apple_sdk.frameworks; [ Security ]);

  sourceRoot = "pijul/pijul";

  # https://nest.pijul.com/pijul_org/pijul/issues/439c4a14-698e-4d2b-9264-2ca4c3d60e3e
  doCheck = false;

  meta = {
    description = "A patch-based distributed version control system";
    homepage    = https://pijul.org;
    license     = stdenv.lib.licenses.gpl2;
    platforms   = stdenv.lib.platforms.unix;
  };
}
