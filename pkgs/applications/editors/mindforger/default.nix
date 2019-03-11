{ stdenv, fetchurl, cmake, qmake, qtbase, qtwebkit }:

stdenv.mkDerivation rec {
  pname = "mindforger";
  version = "1.49.0";

  src = fetchurl {
    url = "https://github.com/dvorka/${pname}/releases/download/${version}/${pname}_${version}.tgz";
    sha256 = "1s33d6b7hdhhy5ji133ipklw72i205k1m8bjm5b80mrmb0kpsnjd";
  };

  nativeBuildInputs = [ cmake qmake ] ;
  buildInputs = [ qtbase qtwebkit ] ;

  doCheck = true;

  enableParallelBuilding = true ;

  patches = [ ./build.patch ] ;

  postPatch = ''
    substituteInPlace deps/discount/version.c.in --subst-var-by TABSTOP 4
    substituteInPlace app/resources/gnome-shell/mindforger.desktop --replace /usr "$out"
  '';

  preConfigure = ''
    pushd deps/cmark-gfm
    mkdir build && cd build
    cmake -DCMARK_TESTS=OFF -DCMARK_SHARED=OFF ..
    cmake --build .
    popd

    export AC_PATH="$PATH"
    pushd deps/discount
    ./configure.sh
    popd
  '';

  dontUseCmakeConfigure = true;
  qmakeFlags = [ "-r mindforger.pro" "CONFIG+=mfnoccache" ] ;

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
