{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  inherit stdenv autoconf automake fetchurl perl python bzip2 zlib openssl lzma curl ncurses;
  version = "1.3.2";

in 
{
  htslibForCnvnator = stdenv.mkDerivation rec {

    name = "htslibForCnvNator";

    src = fetchurl {
      name = "htslib.tar.gz";
      url = "https://github.com/samtools/htslib/archive/${version}.tar.gz";
      sha256 = "1yxs4dcpjf63gyq46mpxjmshikz167vmvznbvnzhiwsgxa40j42m";
    };

    nativeBuildInputs = [ perl ];

    buildInputs = [ zlib bzip2 lzma curl openssl ];

    configureFlags = [ "--enable-libcurl" "--with-libdeflate" ];

    preInstall = ''
      echo "standing directory before install"
      pwd
      ls -hal
    '';

    installFlags = "prefix=$(out)";

    postInstall = ''
      echo "out after install:"
      ls -ahl $out

      echo "creating lib and include"
      mkdir -p $out/lib
      mkdir -p $out/include

      ls -hal $out/lib
      ls -hal $out/include
    '';
    
    preCheck = ''
      patchShebangs test/
    '';

    enableParallelBuilding = true;

    doCheck = true;




  };  
  
}
