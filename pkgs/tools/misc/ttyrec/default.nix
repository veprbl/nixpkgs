{ stdenv, fetchurl, fetchzip }:

stdenv.mkDerivation rec {
  name = "ttyrec-${version}";
  version = "1.0.8";

  src = fetchurl {
    url = "http://0xcc.net/ttyrec/${name}.tar.gz";
    sha256 = "ef5e9bf276b65bb831f9c2554cd8784bd5b4ee65353808f82b7e2aef851587ec";
  };

  postPatch = let debPatch = fetchzip {
    url = http://deb.debian.org/debian/pool/main/t/ttyrec/ttyrec_1.0.8-5.debian.tar.gz;
    sha256 = "09wm4abj8bf2pirs882ri4kddn8ba6hz8hz5q2ffa3k4ifn98s2d";
  }; in ''
    for patch in $(cat ${debPatch}/patches/series); do
      patch -p1 < "${debPatch}/patches/$patch"
    done
  '';

  # TODO: check if cc still needs to be set on darwin
  #makeFlags = stdenv.lib.optional stdenv.cc.isClang "CC=clang";

  installPhase = ''
    mkdir -p $out/{bin,man}
    cp ttytime ttyplay ttyrec $out/bin
    cp *.1 $out/man
  '';

  meta = with stdenv.lib; {
    homepage = http://0xcc.net/ttyrec/;
    description = "Terminal interaction recorder and player";
    license = licenses.bsd3;
    platforms = platforms.all;
    maintainers = with maintainers; [ zimbatm ];
  };
}
