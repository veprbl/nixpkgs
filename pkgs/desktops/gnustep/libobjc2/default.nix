{ stdenv, lib, fetchFromGitHub, cmake }:

let
  version = "2.0";
in

stdenv.mkDerivation rec {
  name = "libobjc2-${version}";

  src = fetchFromGitHub {
    owner = "gnustep";
    repo = "libobjc2";
    rev = "v${version}";
    sha256 = "1b4h0a4pqr8j6300qr2wmi33r7ysvp705gs0ypx69hbmifln0mlf";
  };

  buildInputs = [ cmake ];

  cmakeFlags = [ "-DCMAKE_INSTALL_LIBDIR=lib" ];

  meta = with lib; {
    description = "Objective-C runtime for use with GNUstep";
    homepage = http://gnustep.org/;
    license = licenses.mit;
    maintainers = with maintainers; [ ashalkhakov matthewbauer ];
    platforms = platforms.unix;
    badPlatforms = [ "aarch64-linux" ];
  };
}
