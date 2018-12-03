{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  name = "${pname}-${version}";
  pname = "vivid";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = pname;
    rev = "v${version}";
    sha256 = "08a01qpbyfc65a1yhafwsz74c8ygc1bnp1nb7a25hz2bjvgsy8fc";
  };

  cargoSha256 = "156wapa2ds7ij1jhrpa8mm6dicwq934qxl56sqw3bgz6pfa8fldz";

  postInstall = ''
    mkdir -p $out/share/${pname}
    cp -rv config themes $out/share/${pname}
  '';

  meta = with stdenv.lib; {
    description = "A generator for LS_COLORS with support for multiple color themes";
    homepage = https://github.com/sharkdp/vivid;
    license = with licenses; [ asl20 /* or */ mit ];
    maintainers = [ maintainers.dtzWill ];
    platforms = platforms.linux;
  };
}
