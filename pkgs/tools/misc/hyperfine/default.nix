{ stdenv, fetchFromGitHub, rustPlatform
, Security
}:

rustPlatform.buildRustPackage rec {
  name = "hyperfine-${version}";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner  = "sharkdp";
    repo   = "hyperfine";
    rev    = "refs/tags/v${version}";
    sha256 = "1mn5nv3zljj2wz40imf62gknv84f7igslsf59gg1qvhgvgsd98sp";
  };

  cargoSha256 = "1rwh9kyrkk5jza4lx7sf1pln68ljwsv4ccyfvzcvc140y7ya8ps0";

  buildInputs = stdenv.lib.optional stdenv.isDarwin Security;

  meta = with stdenv.lib; {
    description = "Command-line benchmarking tool";
    homepage    = https://github.com/sharkdp/hyperfine;
    license     = with licenses; [ asl20 /* or */ mit ];
    maintainers = [ maintainers.thoughtpolice ];
    platforms   = platforms.all;
  };
}
