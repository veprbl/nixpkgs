{ stdenv, fetchurl, jre }:
stdenv.mkDerivation rec {
  name = "mill-${version}";
  version = "0.3.5";

  src = fetchurl {
    url = "https://github.com/lihaoyi/mill/releases/download/${version}/${version}";
    sha256 = "19ka81f6vjr85gd8cadn0fv0i0qcdspx2skslfksklxdxs2gasf8";
  };

  propagatedBuildInputs = [ jre ] ;

  phases = "installPhase";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ${src} $out/bin/mill
    chmod +x $out/bin/mill
    sed -i '0,/java/{s|java|${jre}/bin/java|}' $out/bin/mill
    sed -i '0,/mill.MillMain/{s|mill.MillMain|mill.MillMain --no-remote-logging|}' $out/bin/mill
    runHook postInstall
  '';

  meta = with stdenv.lib; {
    homepage = https://www.lihaoyi.com/mill;
    license = licenses.mit;
    description = "A build tool for Scala, Java and more";
    maintainers = with maintainers; [ scalavision ];
    platforms = platforms.unix;
  };

}
