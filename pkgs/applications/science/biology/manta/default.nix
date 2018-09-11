{ stdenv, fetchFromGitHub, zlib, pkgconfig, python, boost, cmake, doxygen, ccache }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "manta";
  version = "1.4.0";

  src = fetchFromGitHub {
    repo = pname;
    owner = "Illumina";
    rev = "v${version}";
    sha256 = "019w86zc36jkz2w1asjg7kc7qinl86p5bpyymdzz2xcgqhpza5wb";
  };

  buildInputs = [ pkgconfig zlib python boost cmake doxygen ccache];

  setSourceRoot = ''
    mkdir ../build_manta
    cd ../build_manta
    sourceRoot="`pwd`"
  '';

  configurePhase = ''
    echo "configuring manta .."
    $src/configure --jobs=4 --prefix=$out
    echo "finished configuring manta"
  '';

  CCACHE_DIR=".ccache";
  makeFlags = [ "BOOST_ROOT=${boost}" ];
  
  installPhase = ''
    echo "$BOOST_ROOT";
    export BOOST_ROOT=${boost};
    echo "going to install manta .."
    echo $(pwd)
    echo "moving into src, is it the same?"
    cd $src
    echo "Starting to compile"
    make -j4 install
    make doc
    rm -rf ../build_manta
  '';  

  meta = with stdenv.lib; {
    description = "Manta calls structural variants (SVs) and indels from mapped paired-end sequencing reads";
    license = licenses.gpl3;
    platforms = platforms.linux;
    homepage = https://github.com/Illumina/manta;
    maintainers = [ ];
  };
}
