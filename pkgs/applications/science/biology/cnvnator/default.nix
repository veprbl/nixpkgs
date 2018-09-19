{ stdenv, fetchurl, zlib, bzip2, lzma, curl, pkgconfig, perl, cmake, ncurses, doxygen, ccache, libXpm }:

let 

  cnvnatorVersion = "0.3.3";
  yeppVersion = "1.0.0";
  samtoolsVersion = "1.8";
  rootVersion = "6.06.6";

  srcs = {
    
    cnvnator = fetchurl {
#      url = "https://github.com/abyzovlab/CNVnator/releases/download/v${cnvnatorVersion}/CNVnator_v${cnvnatorVersion}.zip";
      url = "https://github.com/abyzovlab/CNVnator/archive/v${cnvnatorVersion}.tar.gz";
      sha256 = "1hg57wdlg0xs7vylqp4yf95hhpksj7w9dha6ypmmy7ls3zvariaq";
    };

    yeppp = fetchurl {
      url = "https://bitbucket.org/MDukhan/yeppp/downloads/yeppp-${yeppVersion}.tar.bz2";
      sha256 = "1324";
    };

    samtools = fetchurl {
      url = "https://github.com/samtools/samtools/releases/download/${samtoolsVersion}/samtools-${samtoolsVersion}.tar.bz2"; 
      sha256 = "1242354";
    };

    root = fetchurl {
      url = "https://github.com/root-project/root/archive/v${rootVersion}.tar.gz";
      sha256 = "12234";
    };
  
  };

in stdenv.mkDerivation rec {
  name = "CNVnator-${version}";
  pname = "CNVnator";
  version = "0.3.3";

  buildInputs = [ stdenv zlib bzip2 lzma curl pkgconfig perl cmake ncurses doxygen ccache libXpm ];

  src = srcs.cnvnator;

  postUnpack = ''
    ln -sv ${srcs.samtools} $sourceRoot/samtools
    ln -sv ${src.yeppp} $sourceRoot/yeppp
    ln -sv ${src.root} $sourceRoot/root
  '';
  preConfigure = ''
    ls -ahl
    pwd
  '';

  CCACHE_DIR=".ccache";

  meta = with stdenv.lib; {
    description = "CNVnator calls CNV from mapped paired-end sequencing reads";
    license = licenses.gpl3;
    platforms = platforms.linux;
    homepage =  https://github.com/abyzovlab/CNVnator;
    maintainers = [ ];
  };
}
