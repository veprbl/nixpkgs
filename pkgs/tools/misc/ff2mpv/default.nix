{ stdenv, fetchFromGitHub, python3, mpv }:

stdenv.mkDerivation rec {
  pname = "ff2mpv";
  version = "3.2";

  src = fetchFromGitHub {
    owner = "woodruffw";
    repo = pname;
    rev = "0471ff1787199a07d54ad287915084cc881128ff";
    sha256 = "1xzq21l7vljbazrcsz7n5n1v566bfxnms7zmvlid0w9m6sk65hmb";
  };

  dontBuild = true;

  installPhase = ''
    substituteInPlace ff2mpv.json \
      --replace '/home/william/scripts/ff2mpv' \
                '${placeholder "out"}/bin/ff2mpv'
    install -Dt $out/lib/mozilla/native-messaging-hosts ff2mpv.json

    install -Dm755 -T ff2mpv.py $out/bin/ff2mpv
    patchShebangs $out/bin/ff2mpv
    substituteInPlace $out/bin/ff2mpv --replace "'mpv'" "'${mpv}/bin/mpv'"
  '';
}
