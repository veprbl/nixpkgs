{ stdenv, fetchurl, ncurses }:
stdenv.mkDerivation rec {
  pname = "mmh";
  version = "0.4";
  buildInputs = [ ncurses ];
  patches = [
    ./patches/adjust-bash-completion-script.patch
    ./patches/fix-spelling-errors.patch
    ./patches/multipart-ascii.patch
  ];
  src = fetchurl {
    url = "http://marmaro.de/prog/mmh/files/mmh-${version}.tar.gz";
    sha256 = "13hh54cnj8z4j4d2gr7mvabpk6prj0fsmn7dal6jc329zmdh1a6d";
  };
  meta = with stdenv.lib; {
    description = "Set of electronic mail handling programs";
    homepage = "http://marmaro.de/prog/mmh";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ kaction ];
  };
}
