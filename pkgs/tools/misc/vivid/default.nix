{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  name = "${pname}-${version}";
  pname = "vivid";
  version = "2018-12-02";

  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = pname;
    #rev = "v${version}";
    rev = "39f510cbcc3f7acea47305cd9c7c8efd3dcdddf4";
    sha256 = "1v2jnc4aqisz38q7la9y2igjqqnf0gri1dgf3k3453c7ifb5ndhg";
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
