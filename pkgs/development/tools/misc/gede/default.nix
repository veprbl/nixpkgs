{ stdenv, fetchurl, makeWrapper, python, qmake, universal-ctags, gdb }:

stdenv.mkDerivation rec {
  name = "gede-${version}";
  version = "2.13.1";

  src = fetchurl {
    url = "http://gede.acidron.com/uploads/source/${name}.tar.xz";
    sha256 = "00qgp45hgcnmv8qj0vicqmiwa82rzyadcqy48xfxjd4xgf0qy5bk";
  };

  nativeBuildInputs = [ qmake makeWrapper python ];

  buildInputs = [ universal-ctags ];

  dontUseQmakeConfigure = true;

  buildPhase = ":";

  installPhase = ''
    python build.py --verbose --prefix="$out"
    python build.py --verbose --prefix="$out" install
    wrapProgram $out/bin/gede \
      --prefix PATH : ${stdenv.lib.makeBinPath [ universal-ctags gdb ]}
  '';

  meta = with stdenv.lib; {
    description = "Graphical frontend (GUI) to GDB";
    homepage = http://gede.acidron.com;
    license = licenses.bsd2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ juliendehos ];
  };
}
