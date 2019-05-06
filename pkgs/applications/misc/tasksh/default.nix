{ stdenv, fetchurl, cmake, readline, fetchFromGitHub }:

stdenv.mkDerivation rec {
  #name = "tasksh-${version}";
  pname = "tasksh";
  #version = "1.2.0";
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
  #src = fetchurl {
  #  url = "https://taskwarrior.org/download/${name}.tar.gz";
  #  sha256 = "1z8zw8lld62fjafjvy248dncjk0i4fwygw0ahzjdvyyppx4zjhkf";
  #};

  buildInputs = [ readline ];
  nativeBuildInputs = [ cmake ];

  meta = with stdenv.lib; {
    description = "REPL for taskwarrior";
    homepage = http://tasktools.org;
    license = licenses.mit;
    maintainers = with maintainers; [ matthiasbeyer ];
    platforms = platforms.linux;
  };
}
