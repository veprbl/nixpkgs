{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "gomuks-${version}";
  version = "2019-02-12";

  goPackagePath = "maunium.net/go/gomuks";

  src = fetchFromGitHub {
    owner = "tulir";
    repo = "gomuks";
    rev = "01523ae8cee20695eb6e9d0c4ecd705c6a317baa";
    sha256 = "04cpqyglf4nrnvrz8drz22n8rqks70ivb4vh18k21bdn87g1vbnp";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    homepage = https://maunium.net/go/gomuks/;
    description = "A terminal based Matrix client written in Go";
    license = licenses.gpl3;
    maintainers = with maintainers; [ tilpner ];
    platforms = platforms.unix;
  };
}
