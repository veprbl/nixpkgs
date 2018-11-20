{ stdenv, fetchurl, ccache, qmake, qtbase, qtwebkit }:

stdenv.mkDerivation rec {
  name = "mindforger-${version}";
  version = "1.48.2";

  src = fetchurl {
    url = "https://github.com/dvorka/mindforger/releases/download/1.48.0/mindforger_${version}.tgz";
    sha256 = "1wlrl8hpjcpnq098l3n2d1gbhbjylaj4z366zvssqvmafr72iyw4";
  };

  nativeBuildInputs = [ qmake ccache ] ;
  buildInputs = [ qtbase qtwebkit ] ;

  doCheck = true;

  patches = [ ./build.patch ] ;

  preConfigure = ''
    pushd deps/discount
    ./configure.sh
    popd
    export CCACHE_DIR="$TMP/ccache"
  '';

  qmakeFlags = [ "-r mindforger.pro" ] ;

  meta = with stdenv.lib; {
    description = "Thinking Notebook & Markdown IDE";
    longDescription = ''
     MindForger is actually more than an editor or IDE - it's human
     mind inspired personal knowledge management tool
    '';
    homepage = https://www.mindforger.com;
    license = licenses.gpl2Plus;
    platforms = platforms.all;
  };
}
