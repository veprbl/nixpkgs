{ stdenv, fetchFromGitHub, fetchpatch, cmake, python, boost, libzip, sqlite, xxd }:

stdenv.mkDerivation rec {
  name = "cryptominisat-${version}";
  version = "5.6.3";

  src = fetchFromGitHub {
    owner  = "msoos";
    repo   = "cryptominisat";
    rev    = version;
    sha256 = "0902dy2k5qkvav9qc4b4nvz7bynsahb46llms46bnpamb0rqnzc8";
    fetchSubmodules = true;
  };

  buildInputs = [ boost libzip sqlite python xxd ];
  nativeBuildInputs = [ cmake ];

  meta = with stdenv.lib; {
    description = "An advanced SAT Solver";
    homepage    = https://github.com/msoos/cryptominisat;
    license     = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms   = platforms.unix;
  };
}
