{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "jid";
  version = "0.7.6";

  src = fetchFromGitHub {
    owner = "simeji";
    repo = "jid";
    rev = "v${version}";
    sha256 = "15fgi7cpq5bg2lnpr7rip359xwj2kvlj6j2qzi837c26adnw973x";
  };

  modSha256 = "0hsfqy098sj7y9lhsnn3w1mxl4h81977ks5njmk6dkdki6vcngjj";

  meta = {
    description = "A command-line tool to incrementally drill down JSON";
    homepage = https://github.com/simeji/jid;
    license = stdenv.lib.licenses.mit;
    platforms = stdenv.lib.platforms.all;
    maintainers = with stdenv.lib.maintainers; [ stesie ];
  };
}
