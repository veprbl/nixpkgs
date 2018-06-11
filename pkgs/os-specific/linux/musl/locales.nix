{ stdenv, fetchFromGitLab, cmake, gettext }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "musl-locales";
  version = "2018-04-16";

  src = fetchFromGitLab {
    owner = "rilian-la-te";
    repo = pname;
    rev = "5c93044fffdc9d07865d69bc7ebce4aa129f8eeb";
    sha256 = "05czzs8f3d23p9s09w4jlmswi57z9siwkqzfqhds6mzfa11f5lyk";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ gettext ];
}
