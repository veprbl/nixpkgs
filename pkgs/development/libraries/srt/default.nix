{ stdenv, fetchFromGitHub, cmake, openssl
}:

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "srt-${version}";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "Haivision";
    repo = "srt";
    rev = "v${version}";
    sha256 = "0cv73j9c8024p6pg16c4hiryiv4jpgrfj2xhfdaprsikmkdnygmz";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ openssl ];

  configurePhase = "cmake . -DCMAKE_INSTALL_PREFIX=$out";

  meta = {
    description = "Secure, Reliable, Transport";
    homepage    = https://www.srtalliance.org;
    license     = licenses.mpl20;
    maintainers = with maintainers; [ nh2 ];
    platforms   = platforms.all;
  };
}
