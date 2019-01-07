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
    rev = "a4269db334b4dc4207f876afa26f5e5650fdff53";
    sha256 = "0v1v1m1ryblib38fs8vyihgb4xsf0k7fr2m2lf6myl73cg5pp2j8";
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
