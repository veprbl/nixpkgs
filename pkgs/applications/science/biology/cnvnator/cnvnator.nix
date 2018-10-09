{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  inherit stdenv autoconf automake fetchurl perl python xlibs bzip2 zlib openssl lzma curl ncurses;
  version = "0.3.5";
  rootVersion = "6.06.6";
  yeppVersion = "1.0.0";
  samtoolsVersion = "1.3.1";
  htslibVersion = "1.3.1";
  srcs = {
    
    rootSrc = fetchurl {
      name = "cernRoot.tar.gz";
      url = "https://root.cern.ch/download/root_v${rootVersion}.source.tar.gz";
      sha256 = "1557b9sdragsx9i15qh6lq7fn056bgi87d31kxdl4vl0awigvp5f";
    };

    cnvnator = fetchFromGitHub {
      owner = "abyzovlab";
      repo = "CNVnator";
      rev = "de012f2bccfd4e11e84cf685b19fc138115f2d0d";
      sha256 = "0fs6a7krwk0w55fgfbv7m5vk9brllf6pk5dmy3rkpdmdk9mslr2j";
    };

    yepppSrc = fetchurl {
      name = "yepp.tar.bz2";
      url = "https://bitbucket.org/MDukhan/yeppp/downloads/yeppp-${yeppVersion}.tar.bz2";
      sha256 = "0gacil1xvvpj5vyrrbdyrxxxy74zfdi9rn9jlplx0scrf9pacbh4";
    };
    
    htslibSrc4 = fetchurl {
      name = "htslib.tar.gz";
      url = "https://github.com/samtools/htslib/archive/1.4.1.tar.gz";
      sha256 = "0qjmsay4z3vn8n2p662p2ivg3yp18h75c5s7jawj63s6in4rr5sz";
      #sha256 = "19ryv40mw0y2x1vsk2kfx3jjxb4l129836nisnmh3hy4l3wh9g9x";
    };

    samtoolsSrc4 = fetchurl { 
      name = "samtools.tar.gz";
      sha256 = "1f5k97nfxq2i2w3xh3j1srwv2yyv6whqnhgdwi5qh8a135icxvm0";
      #sha256 = "0s57jngp253alz774dg9cs4qrddy84m3p60p81pi97ndj9xjqx9x";
#      sha256 = "1anccdxciaw17y3zj9809sq2il24qnlmygd3ir74a5v9fgc5wjxv";
      url = "https://github.com/samtools/samtools/archive/1.4.1.tar.gz";
    };

    /*
    samtoolsSrc = fetchFromGitHub {
      owner = "samtools";
      repo = "samtools";
      rev = "897c0027a04501e3ea33d94b5cdeb633d010da8d";
      #url = "https://github.com/samtools/samtools/archive/1.3.1.tar.gz";
      sha256 = "1anccdxciaw17y3zj9809sq2il24qnlmygd3ir74a5v9fgc5wjxv";
      };
      */
  
  };

in
{
    cnvnator = stdenv.mkDerivation rec {
      name = "cnvnator-${version}";


      buildInputs = [ autoconf automake perl python bzip2 zlib openssl lzma curl ncurses xlibs.libX11 ]; # python xlibs bzip2 zlib openssl lzma curl ncurses ];

      src = srcs.cnvnator;

      preConfigure = ''
        mkdir -p $sourceRoot/htslib
        mkdir -p $sourceRoot/samtools

        tar xvfz ${srcs.htslibSrc4} -C $sourceRoot/htslib --strip-components=1
        tar xvfz ${srcs.samtoolsSrc4} -C $sourceRoot/samtools --strip-components=1

        echo "content of source"
        ls -hal $sourceRoot
        echo "content of samtools"
        ls -hal $sourceRoot/samtools
        ls -hal $sourceRoot/htslib

        cd $sourceRoot/samtools

        patchShebangs test/
        autoheader
        autoconf -Wno-syntax  # Generate the configure script
#        ./configure --help
        ./configure --with-htslib=../htslib/hstlib # = "$sourceRoot/htslib"
        make
      '';

    };
      
}

