{ stdenv, fetchurl, jre, icedtea8_web, rpmextract, xorg, makeWrapper }:

stdenv.mkDerivation rec {
  name = "eZuceSRN-${version}";
  version = "3.4.1";

  src = fetchurl {
    url = "http://srn.ezuce.com/download/legacy/eZuceSRN_linux_64bits_3_4_1.rpm";
    sha256 = "16il1wq27v4b3v45fp2bcr5yhld2jqs4rxlh4azgl8x0ikdksls8";
  };

  buildInputs = with xorg; [ libX11 ];
  nativeBuildInputs = [ makeWrapper ];

  unpackPhase = ''
    ${rpmextract}/bin/rpmextract $src
  '';
#common_jvm_locations=
  buildPhase = ''
    #cat opt/eZuceSRN/jre/./release
    #rm -rf opt/eZuceSRN/jre
for i in opt/eZuceSRN/jre/bin/*; do
patchelf --set-interpreter ${stdenv.cc.libc.out}/lib/ld-linux-x86-64.so.2 $i || true
done
#patchelf opt/eZuceSRN/jre/lib/amd64/libawt_xawt.so \
#--set-rpath ${stdenv.lib.makeLibraryPath (with xorg; [ libX11 libXext libXi ])}
#patchelf opt/eZuceSRN/jre/lib/amd64/libawt_xawt.so --show-rpath
  '';

  installPhase = ''
    mkdir $out
    cp -r opt $out/
    wrapProgram $out/opt/eZuceSRN/eZuceSRN --prefix LD_LIBRARY_PATH : ${stdenv.lib.makeLibraryPath (with xorg; [ libX11 libXext libXi libXrender libXtst ])}
  '';
    #wrapProgram $out/opt/eZuceSRN/eZuceSRN --set INSTALL4J_JAVA_HOME ${jre} --prefix PATH : ${stdenv.lib.makeBinPath [ icedtea8_web ]}
    #wrapProgram $out/opt/eZuceSRN/eZuceSRN --prefix PATH : ${stdenv.lib.makeBinPath [ jre icedtea8_web ]}
    #wrapProgram $out/opt/eZuceSRN/eZuceSRN --prefix PATH : ${stdenv.lib.makeBinPath [ jre ]}
    #wrapProgram $out/opt/eZuceSRN/eZuceSRN --set INSTALL4J_JAVA_HOME $out/opt/eZuceSRN/jre
}
