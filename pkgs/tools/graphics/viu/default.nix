{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "viu";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "atanunq";
    repo = "viu";
    #rev = "v${version}";
    rev = "712241291081d5dae6aca5a5f1d80d219997f074";
    sha256 = "16g0ip5i1iw3mxxsr0n70n79rvk0vac2cmxmzpl3ylw45sa3qvnl";
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
