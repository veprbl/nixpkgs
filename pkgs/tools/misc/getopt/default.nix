{stdenv, fetchurl}:

stdenv.mkDerivation rec {
  pname = "getopt";
  version = "1.1.6";
  builder = ./builder.sh;
  src = fetchurl {
    url = "http://frodo.looijaard.name/system/files/software/${pname}/${pname}-${version}.tar.gz";
    sha256 = "1zn5kp8ar853rin0ay2j3p17blxy16agpp8wi8wfg4x98b31vgyh";
  };
  preBuild = ''
    export buildFlags=CC="$CC" # for darwin
  '';

  meta = {
    platforms = stdenv.lib.platforms.unix;
  };
}
