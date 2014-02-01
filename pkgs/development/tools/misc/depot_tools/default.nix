{ fetchgit, stdenv, makeWrapper, python27, git, subversion, less, bash
, coreutils, findutils, gnugrep }:

let
  PATH = "${python27}/bin:${git}/bin:${subversion}/bin:${less}/bin:" +
         "${bash}/bin:${coreutils}/bin:${findutils}/bin:${gnugrep}/bin";
in stdenv.mkDerivation {
  name = "depot_tools-d8b6599b1";

  src = fetchgit {
    url = "https://chromium.googlesource.com/chromium/tools/depot_tools.git";
    rev = "d8b6599b158ee5f9cdd675e078aa91dd8a418ecc";
    sha256 = "1myr32n3vbp5ilfi6qijhbc32pzglwwqkq4r1sq5a2gmclym27b3";
  };

  buildInputs = [ makeWrapper ];

  installPhase = ''
    ensureDir $out/share/depot_tools/
    ensureDir $out/bin
    cp -r $src/* $out/share/depot_tools/
    chmod -R +w $out/share/depot_tools

    # Add only tools you need
    makeWrapper $out/share/depot_tools/gclient $out/bin/gclient --prefix PATH : "${PATH}"
    makeWrapper $out/share/depot_tools/repo $out/bin/repo --prefix PATH : "${PATH}"
  '';
}
