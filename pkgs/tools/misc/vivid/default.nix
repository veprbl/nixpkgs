{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  name = "${pname}-${version}";
  pname = "vivid";
  #version = "0.4.0";
  version = "2019-01-04";

  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = pname;
    #rev = "v${version}";
    rev = "9a11c00563e009e940ef5bee5808f55b36c0f5b1";
    sha256 = "1d47zgapsfg2acg1929372g8ivrrx4aqxgq3n1lhwar37wqndin6";
  };

  patches = [
    # PR 26
    ./jellybean.patch
  ];

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
