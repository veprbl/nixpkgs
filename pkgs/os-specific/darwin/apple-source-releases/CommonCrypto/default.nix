{ stdenv, appleDerivation }:

appleDerivation {
  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    mkdir -p $out/include/CommonCrypto
    cp include/* $out/include/CommonCrypto
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [ copumpkin ];
    platforms   = platforms.unix;
    license     = licenses.apsl20;
  };
}
