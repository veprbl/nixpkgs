{ stdenv, fetchurl, cmake, git, readline, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "tasksh";
  version = "2019-05-06";

  enableParallelBuilding = true;

  src = fetchFromGitHub {
    owner = "GothenburgBitFactory";
    repo = "taskshell";
    rev = "954431793a9c58720913d32e91653b23986447c3"; # 1.3.0, moving
    sha256 = "0pmsxdhy40j6c0v9llhn4z7gcz7d89icbwjcgms49skl3yiskyg7";
    fetchSubmodules = true;
    leaveDotGit = true;
  };

  buildInputs = [ readline ];
  nativeBuildInputs = [ cmake git ];

  preConfigure = "touch .git/index";

  meta = with stdenv.lib; {
    description = "REPL for taskwarrior";
    homepage = http://tasktools.org;
    license = licenses.mit;
    maintainers = with maintainers; [ matthiasbeyer ];
    platforms = platforms.linux;
  };
}
