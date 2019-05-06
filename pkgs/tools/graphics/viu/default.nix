{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "viu";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "atanunq";
    repo = "viu";
    #rev = "v${version}";
    rev = "1dcc30e1aad4402936a814fd3aaf68d1afb307f4";
    sha256 = "1g8fc6chaw1rjhqp2li6m9xri47sha2fcfkq7qq04cqs847sx33j";
  };

  cargoSha256 = "1h9dm2hhld2079dnx4x5nzkn3ivk6g5ijhv49jxnc200mx4mr1s5";

  meta = with lib; {
    description = "A command-line application to view images from the terminal written in Rust";
    homepage = "https://github.com/atanunq/viu";
    license = licenses.mit;
    maintainers = with maintainers; [ petabyteboy ];
    platforms = platforms.all;
  };
}
