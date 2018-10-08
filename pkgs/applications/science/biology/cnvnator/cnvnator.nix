{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  inherit stdenv fetchurl perl python xlibs bzip2 zlib openssl lzma curl ncurses;
  version = "0.3.4";
  yeppVersion = "1.0.0";
  samtoolsVersion = "1.3.1";
  htslibVersion = "1.3.1";
      srcs = {
        
        rootSrc = fetchurl {
          url = "https://root.cern.ch/download/root_v${version}.source.tar.gz";
          sha256 = "1557b9sdragsx9i15qh6lq7fn056bgi87d31kxdl4vl0awigvp5f";
        };

        cnvnator = fetchFromGitHub {
          owner = "abyzovlab";
          repo = "CNVnator";
          rev = "de012f2bccfd4e11e84cf685b19fc138115f2d0d";
          sha256 = "0fs6a7krwk0w55fgfbv7m5vk9brllf6pk5dmy3rkpdmdk9mslr2j";
        };

        yepppSrc = fetchurl {
          url = "https://bitbucket.org/MDukhan/yeppp/downloads/yeppp-${yeppVersion}.tar.bz2";
          sha256 = "0gacil1xvvpj5vyrrbdyrxxxy74zfdi9rn9jlplx0scrf9pacbh4";
        };
        
        htslibSrc = fetchurl {
          url = "https://github.com/samtools/htslib/archive/1.3.1.tar.gz";
          sha256 = "19ryv40mw0y2x1vsk2kfx3jjxb4l129836nisnmh3hy4l3wh9g9v";
        };

        samtoolsSrc = fetchFromGitHub {
          owner = "samtools";
          repo = "samtools";
          rev = "897c0027a04501e3ea33d94b5cdeb633d010da8d";
          #url = "https://github.com/samtools/samtools/archive/1.3.1.tar.gz";
          sha256 = "1anccdxciaw17y3zj9809sq2il24qnlmygd3ir74a5v9fgc5wjxv";
        };
      
      };
in
{
    cnvnator = stdenv.mkDerivation rec {
      name = "cnvnator-${version}";


      buildInputs = [ perl python bzip2 zlib openssl lzma curl ncurses xlibs.libX11 ]; # python xlibs bzip2 zlib openssl lzma curl ncurses ];

      src = srcs.cnvnator;

      postUnpack = ''
        rm -rf $sourceRoot/samtools
        rm -rf $sourceRoot/htslib

        mkdir -p $sourceRoot/htslib
        echo "Extracting.."
        
        tar xvfz ${srcs.htslibSrc} -C $sourceRoot/htslib --strip-components=1
        echo "Content of htslib:"
        ls -ahl $sourceRoot/htslib

        echo "Working on samtools ..."
        mkdir -p $sourceRoot/samtools
        ls -hal ${srcs.samtoolsSrc}
#        tar xvfz ${srcs.samtoolsSrc} -C $sourceRoot/samtools --strip-components=1

        echo "Content of samtools:"
        ls -hal $sourceRoot/samtools

        echo "############## Finished samtools!"
      '';
    };

}

