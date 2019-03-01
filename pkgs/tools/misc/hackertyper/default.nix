{ stdenv, fetchFromGitHub, ncurses }:

stdenv.mkDerivation rec {
  pname = "hackertyper";
  version = "20190226";

  src = fetchFromGitHub {
    owner  = "Hurricane996";
    repo   = "Hackertyper";
    rev    = "dc017270777f12086271bb5a1162d0f3613903c4";
    sha256 = "14f7pfjp28iqy0hby50sdx602zva4g3d0ndvwzs03qq262rgd6n4";
  };


  makeFlags = [ "PREFIX=$(out)" ];
  buildInputs = [ ncurses ];

  preInstall = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1
  '';



  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/hackertyper -v
  '';

  meta = with stdenv.lib; {
    description = "A C rewrite of hackertyper.net";
    homepage = https://github.com/Hurricane996/Hackertyper;
    license = licenses.gpl3;
    maintainers = [ maintainers.marius851000 ];
  };
}
