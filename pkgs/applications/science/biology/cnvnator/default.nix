{ pkgs, stdenv, ocaml, fetchFromGitHub, fetchurl,  samtools, zlib, bzip2, lzma, curl, pkgconfig, perl, ncurses, doxygen, ccache, libXpm }:
# The call.package of nix will ensure that the packages above is passed in appropriately
let 

  cnvnatorVersion = "0.3.3";
  yeppVersion = "1.0.0";

  root = pkgs.root.overrideAttrs (oldAttrs: rec {
    
    name = "root-${version}";
    version = "6.06.6";

    src = fetchurl {
      url = "https://root.cern.ch/download/root_v${version}.source.tar.gz";
      sha256 = "1557b9sdragsx9i15qh6lq7fn056bgi87d31kxdl4vl0awigvp5f";
    };

  });

  srcs = {

    /*
    cnvnator = fetchurl {
      url = "https://github.com/abyzovlab/CNVnator/archive/v${cnvnatorVersion}.tar.gz";
      sha256 = "1hg57wdlg0xs7vylqp4yf95hhpksj7w9dha6ypmmy7ls3zvariaq";
    };*/

    cnvnator = fetchFromGitHub {
      owner = "abyzovlab";
      repo = "CNVnator";
      rev = "de012f2bccfd4e11e84cf685b19fc138115f2d0d";
      sha256 = "0fs6a7krwk0w55fgfbv7m5vk9brllf6pk5dmy3rkpdmdk9mslr2j";
    };

    yeppp = fetchurl {
      url = "https://bitbucket.org/MDukhan/yeppp/downloads/yeppp-${yeppVersion}.tar.bz2";
      sha256 = "0gacil1xvvpj5vyrrbdyrxxxy74zfdi9rn9jlplx0scrf9pacbh4";
    };
  
  };

in stdenv.mkDerivation rec {
  name = "CNVnator-${version}";
  pname = "CNVnator";
  version = "0.3.3";

  buildInputs = [ stdenv ocaml zlib root samtools bzip2 lzma curl pkgconfig perl ncurses doxygen ccache libXpm ];

  src = srcs.cnvnator;

  postUnpack = ''
    ln -sv ${srcs.yeppp} $sourceRoot/yeppp
  '';

  preConfigure = ''

    cat Makefile

    echo "content of this directory:"
    ls -ahl
    echo "active directory is":
    pwd

    echo "content of root"
    ls ${root}

    echo "content of samtools"
    ls ${samtools}

    echo "root is located at"
    cd ${root}
    pwd
    cd -

    echo "samtools is located at:"
    cd ${samtools}
    pwd
    cd -

    tar -xvjf ${samtools.src}
    echo "What do we have here?"
    ls -ahl
    pwd
    cd samtools-${samtools.version}
    echo "What do we have here?"
    ls -ahl
    pwd
    ./configure --without-curses --enable-libcurl
    make

    cd ../ 
  '';

  CCACHE_DIR=".ccache";

  preBuild = '' 
    echo "going to build cnvnator ..."
    pwd
    ls -ahl
    mv samtools-${samtools.version} samtools

    echo >> MakeFile
    echo >> MakeFile

    echo "install:  cnvnator" >> MakeFile

    cat MakeFile
  '';

  meta = with stdenv.lib; {
    description = "CNVnator calls CNV from mapped paired-end sequencing reads";
    license = licenses.gpl3;
    platforms = platforms.linux;
    homepage =  https://github.com/abyzovlab/CNVnator;
    maintainers = [ ];
  };
}
