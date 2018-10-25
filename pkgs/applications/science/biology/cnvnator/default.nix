{ stdenv, lib, fetchFromGitHub, perl, htslib, samtools, root, yeppp, curl, openssl, bzip2, zlib, lzma, ncurses }:
let 

  cnvnatorVersion = "0.3.3";
  yeppVersion = "1.0.0";
  samtoolsVersion = "1.3.1";
  htslibVersion = "1.3.2";

  root = pkgs.root.overrideAttrs (oldAttrs: rec {
    
    name = "root-${version}";
    version = "6.06.6";

    src = fetchurl {
      url = "https://root.cern.ch/download/root_v${version}.source.tar.gz";
      sha256 = "1557b9sdragsx9i15qh6lq7fn056bgi87d31kxdl4vl0awigvp5f";
    };

  });

  htslib = pkgs.htslib.overrideAttrs (oldAttrs: rec{
    
    name = "htslib-${htslibVersion}";
    src = fetchurl {
      url =  "https://github.com/samtools/htslib/releases/download/${htslibVersion}/${name}.tar.bz2";
      sha256 = "1rja282fwdc25ql6izkhdyh8ppw8x2fs0w0js78zgkmqjlikmma9";
    };

  });
  
  samtools = pkgs.samtools.overrideAttrs (oldAttrs: rec {
    
    name = "samtools-${version}";
    version = "1.3.1";

    src = fetchurl {
      url = "https://github.com/samtools/samtools/releases/download/${version}/${name}.tar.bz2";
      sha256 = "1557b9sdragsx9i15qh6lq7fn056bgi87d31kxdl4vl0awigvp5f";
    };

    #ncurses = ncurses;

    preConfigure = ''
      echo PreConfiguring
      pwd
      ls -ahl
      echo "Trying to remove all bash things ..."
      patchShebangs ./.
      patchShebangs configure
      ./configure --help
      '';
      */
/*
    preCheck = ''
      pwd
      ls -ahl
      cat configure.ac | grep bash
      patchShebangs ./.
      patchShebangs configure
      patchShebangs ./configure.ac
      patchShebangs test/
      '';
      */

     #configureFlags = [ "--with-htslib=${htslib}" ] ++ stdenv.lib.optional (ncurses == null) "--without-curses";



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
    
    htslib = fetchurl {
#      url = "https://github.com/samtools/htslib/releases/download/1.3.1/htslib-${htslibVersion}.tar.bz2";
      url = "https://github.com/samtools/htslib/archive/1.3.1.tar.gz";
      sha256 = "19ryv40mw0y2x1vsk2kfx3jjxb4l129836nisnmh3hy4l3wh9g9v";
      #sha256 = "1rja282fwdc25ql6izkhdyh8ppw8x2fs0w0js78zgkmqjlikmma9";
    };

    samtools = fetchurl {
      url = "https://github.com/samtools/samtools/archive/1.3.1.tar.gz";
      #url = "https://github.com/samtools/samtools/releases/download/${samtoolsVersion}/samtools.tar.bz2";
      sha256 = "1557b9sdragsx9i15qh6lq7fn056bgi87d31kxdl4vl0awigvp5f";
    };
  
  };

in stdenv.mkDerivation rec {
  name = "CNVnator-${version}";
  pname = "CNVnator";
  version = "0.3.3";

  buildInputs = [ autoconf automake python libX11 stdenv ocaml zlib root bzip2 lzma curl pkgconfig perl openssl ncurses doxygen ccache libXpm ];

  src = srcs.cnvnator;

  postUnpack = ''
    ln -sv ${srcs.yeppp} $sourceRoot/yeppp

    mkdir -p $sourceRoot/htslib
    echo "Extracting.."
    tar xvfz ${srcs.htslib} -C $sourceRoot/htslib --strip-components=1
    echo "Content of htslib:"
    ls -ahl $sourceRoot/htslib

    mkdir -p $sourceRoot/samtools
    echo "Extracting.."
    tar xvfz ${srcs.samtools} -C $sourceRoot/samtools --strip-components=1
    echo "Content of samtools:"
    cd $sourceRoot/samtools
    pwd
    ls -hal $sourceRoot/samtools
    cd -

    echo "Everything lined up?"
    ls -ahl $sourceRoot/
    ls -ahl $sourceRoot/samtools
    ls -ahl $sourceRoot/htslib
  '';

  preConfigure = ''

    echo "content of this directory:"
    ls -ahl
    echo "active directory is":
    pwd

    echo "Entering samtools folder: "
    cd $sourceRoot/samtools

    echo "What do we have here?"
    ls -ahl
    pwd
#    autoheader
#    autoconf -Wno-syntax
#    cat ./configure
    patchShebangs configure
    patchShebangs test/
#    cat ./configure
    ./configure
    make
#    ./configure --without-curses --enable-libcurl

    echo "####################################################"
    echo "####### FINISHED COMPILING SAMTOOLS !!!! ###########"
    echo "####################################################"
  '';

  CCACHE_DIR=".ccache";

  /*
  preBuild = '' 
    echo "going to build cnvnator ..."
    pwd
    ls -ahl

    echo >> Makefile
    echo >> Makefile

    echo "install:  cnvnator" >> Makefile

    cat Makefile
  '';*/

  postInstall = ''
    echo "Result after install?"
    pwd
    ls -hal
    ls -hal | grep cnvnator
    mkdir $out/bin
    cp cnvnator $out/bin
    cp cnvnator2VCF.pl $out/bin
  '';

  preFixup = let
    libPath = lib.makeLibraryPath [
      openssl
      root
      zlib #.so.1 => not found
      bzip2 
      lzma 
      curl
      stdenv
      gcc
      /*
        libbz2.so.1 => not found
        libcurl.so.4 => not found
        liblzma.so.5 => not found
        libCore.so => not found
        libRIO.so => not found
        libHist.so => not found
        libGraf.so => not found
        libGpad.so => not found
        libTree.so => not found
        libMathCore.so => not found
        libstdc++.so.6 => not found
        libgomp.so.1 => not found
        */

#      libcrypto
    ];
  in '' 

    echo "Trying to build library: "

    echo ${openssl}

    patchelf \
      --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}" \
      $out/bin/cnvnator
    '';

  /*
  postBuild = ''
    '';
    */

#  installTargets = "all";

  meta = with stdenv.lib; {
    description = "CNVnator calls CNV from mapped paired-end sequencing reads";
    license = licenses.gpl3;
    platforms = platforms.linux;
    homepage =  https://github.com/abyzovlab/CNVnator;
    maintainers = [ ];
  };
}
