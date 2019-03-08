{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "la-capitaine-icon-theme";
  version = "2019-03-01";

  src = fetchFromGitHub {
    owner = "keeferrourke";
    repo = pname;
    rev = "d641751bd6f27bd9cb4805e6240b2edfe0bfb395";
    sha256 = "0n07vhqz5rfchp44l6nazl2x8a5abpg6v74in9wj63fsj20mxjhq";
  };

  configurePhase = ":";

  installPhase = ''
    mkdir -p $out/share/icons/${pname}
    mv -v * $out/share/icons/${pname}
    rm -rf $out/share/icons/${pname}/{*.md,configure,.git*,.product}
  '';
}

