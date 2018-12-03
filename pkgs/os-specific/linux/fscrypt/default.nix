{ stdenv, buildGoPackage, fetchFromGitHub, pam }:

# Don't use this for anything important yet!

buildGoPackage rec {
  name = "fscrypt-${version}";
  #version = "0.2.4";
  version = "2018-11-20";

  goPackagePath = "github.com/google/fscrypt";

  src = fetchFromGitHub {
    owner = "google";
    repo = "fscrypt";
    #rev = "v${version}";
    rev = "15af139f45208bc8bf1696629c7e8a5dcc2140ce";
    sha256 = "1ix6rdgisykjv318x3dk2w2jnmzir7qdvrm05czrl1chvvq53nz2";
  };

  buildInputs = [ pam ];

  meta = with stdenv.lib; {
    description =
      "A high-level tool for the management of Linux filesystem encryption";
    longDescription = ''
      This tool manages metadata, key generation, key wrapping, PAM integration,
      and provides a uniform interface for creating and modifying encrypted
      directories.
    '';
    inherit (src.meta) homepage;
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ primeos ];
  };
}
