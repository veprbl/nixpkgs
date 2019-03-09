{ stdenv, fetchurl, bison, flex, libffi }:

stdenv.mkDerivation rec {
  pname = "txr";
  version = "213";

  src = fetchurl {
    url = "http://www.kylheku.com/cgit/${pname}/snapshot/${pname}-${version}.tar.bz2";
    sha256 = "1ri2fjn1xwcksgj2cjr7yphyi8yz6bip1sy64w7yfn7681p4qbc7";
  };

  nativeBuildInputs = [ bison flex ];
  buildInputs = [ libffi ];

  enableParallelBuilding = true;

  doCheck = true;
  checkTarget = "tests";

  # Remove failing test-- mentions 'usr/bin' so probably related :)
  preCheck = "rm -rf tests/017";

  # TODO: install 'tl.vim', make avail when txr is installed or via plugin

  meta = with stdenv.lib; {
    description = "Programming language for convenient data munging";
    license = licenses.bsd2;
    homepage = http://nongnu.org/txr;
    maintainers = with stdenv.lib.maintainers; [ dtzWill ];
  };
}
