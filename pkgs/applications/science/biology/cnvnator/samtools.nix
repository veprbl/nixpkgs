{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  inherit stdenv autoconf automake fetchurl perl python bzip2 zlib openssl lzma curl ncurses;
  version = "1.3.1";
  htslibForCnvNator = callPackage ./htslib.nix {};

  #  htslibForCnvNator = import ./htslib.nix { };
  # htslibForCnvNator = import ./htslib.nix pkgs;
in 
{
  samtoolsForCnvNator = stdenv.mkDerivation rec {

    name = "samtoolsForCnvNator";
    
    xlib = htslibForCnvNator;   
    src = fetchurl {
      name = "samtools.tar.gz";
      url = "https://github.com/samtools/samtools/archive/${version}.tar.gz";
      sha256 = "0s57jngp253alz774dg9cs4qrddy84m3p60p81pi97ndj9xjqx9h";
    };

    nativeBuildInputs = [ perl ];

#    buildInputs = [ zlib bzip2 lzma curl openssl ncurses ];

    configureFlags = [ "--with-htslib=${htslibForCnvNator}" ] ++ stdenv.lib.optional (ncurses == null) "--without-curses";

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
