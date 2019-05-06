{ stdenv, fetchurl, fetchFromGitHub }:

stdenv.mkDerivation rec {
  version = "2.2.5";
  pname = "discount";

  src = fetchFromGitHub {
    owner = "Orc";
    repo = pname;
    rev = "v${version}";
    sha256 = "1b2nqnf3cd8bxgnx5ld5mnjn5ln4srvjfa5q9ivfwigg94w6l098";
  };

  patches = ./fix-configure-path.patch;
  configureScript = "./configure.sh";

  configureFlags = [
    "--enable-all-features"
    "--pkg-config"
    "--shared"
    "--with-fenced-code"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Implementation of Markdown markup language in C";
    homepage = http://www.pell.portland.or.us/~orc/Code/discount/;
    license = licenses.bsd3;
    maintainers = with maintainers; [ shell ndowens ];
    platforms = platforms.unix;
  };
}
