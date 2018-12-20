{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  name = "${pname}-${version}";
  pname = "vivid";
  #version = "0.4.0";
  version = "2018-12-09";

  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = pname;
    #rev = "v${version}";
    rev = "d95afe5204c5927a75ffb99570307a90badf3c46";
    sha256 = "0lyhln1gdh4f96jsvwl3qhmp1dac8mfpzmadpb0w2mjix4fhf4ha";
  };

  postPatch = ''
    substituteInPlace src/main.rs --replace /usr/share $out/share
  '';

  cargoSha256 = "156wapa2ds7ij1jhrpa8mm6dicwq934qxl56sqw3bgz6pfa8fldz";

  postInstall = ''
    mkdir -p $out/share/${pname}
    cp -rv config/* themes $out/share/${pname}
  '';

  meta = with stdenv.lib; {
    description = "A generator for LS_COLORS with support for multiple color themes";
    homepage = https://github.com/sharkdp/vivid;
    license = with licenses; [ asl20 /* or */ mit ];
    maintainers = [ maintainers.dtzWill ];
    platforms = platforms.unix;
  };
}
