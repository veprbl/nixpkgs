{ stdenv, fetchFromGitHub, perlPackages }:

assert stdenv ? glibc;

perlPackages.buildPerlPackage rec {
  name = "ninka-${version}";
  version = "2017-04-02";

  src = fetchFromGitHub {
    owner = "dmgerman";
    repo = "ninka";
    rev = "81f185261c8863c5b84344ee31192870be939faf";
    sha256 = "0dbnghpc2fgdx2chsx3m1ksv2p2acjss999ijwhaiwjkja4zgd1c";
  };
  
  buildInputs = with perlPackages; [ perl TestOutput DBDSQLite DBI TestPod TestPodCoverage SpreadsheetParseExcel ];

  doCheck = false;    # hangs

  preConfigure = ''
    sed -i.bak -e 's;#!/usr/bin/perl;#!${perlPackages.perl}/bin/perl;g' \
        ./bin/ninka-excel ./bin/ninka ./bin/ninka-sqlite \
        ./scripts/unify.pl ./scripts/parseLicense.pl \
        ./scripts/license_matcher_modified.pl \
        ./scripts/sort_package_license_list.pl
    perl Makefile.PL
  '';

  meta = with stdenv.lib; {
    description = "A sentence based license detector";
    homepage = http://ninka.turingmachine.org/;
    license = licenses.gpl2;
    maintainers = [ maintainers.vrthra ];
    platforms = platforms.all;
  };
}
