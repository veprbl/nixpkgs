{ stdenv, fetchurl, openssl, libidn, ncurses, pcre, makeWrapper
}:

stdenv.mkDerivation rec {
  name = "hydra-7.5";

  src = fetchurl {
    url = "http://www.thc.org/releases/${name}.tar.gz";
    sha256 = "1dhavbn2mcm6c2c1qw29ipbpmczax3vhhlxzwn49c8cq471yg4vj";
  };

  preConfigure = ''
   substituteInPlace configure --replace "\$LIBDIRS" "${openssl}/lib ${pcre}/lib"
   substituteInPlace configure --replace "\$INCDIRS" "${openssl}/include ${pcre}/include"
  '';

  buildInputs =
    [ makeWrapper openssl libidn ncurses pcre ];
}
