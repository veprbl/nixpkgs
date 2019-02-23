{ lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "drive-${version}";
  version = "0.3.9.1";

  goPackagePath = "github.com/odeke-em/drive";
  subPackages = [ "cmd/drive" ];

  src = fetchFromGitHub {
    owner = "odeke-em";
    repo = "drive";
    rev = "v${version}";
    sha256 = "0mpym9b9jyhp6spz5lz85sbailqvcar1g280h5an4bkiczm3bci5";
  };

  goDeps = ./deps.nix;

  meta = with lib; {
    homepage = https://github.com/odeke-em/drive;
    description = "Google Drive client for the commandline";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
