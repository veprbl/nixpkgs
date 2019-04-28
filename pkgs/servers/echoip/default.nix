{ lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "echoip-${version}";
  version = "unstable-2019-04-27";

  goPackagePath = "github.com/mpolden/echoip";

  src = fetchFromGitHub {
    owner = "mpolden";
    repo = "echoip";
    rev = "27fa828efb9034f359f638d29eda1f84aa08cc48";
    sha256 = "1rp2vgpfc514qgq715rkhhiciz6k8ms19qs31q1an3aapacf446p";
  };

  goDeps = ./deps.nix;

  outputs = [ "bin" "out" ];

  postInstall = ''
    mkdir -p $out
    cp $src/index.html $out/index.html
  '';

  meta = with lib; {
    homepage = https://github.com/mpolden/echoip;
    license = licenses.bsd3;
    maintainers = with maintainers; [ rvolosatovs ];
  };
}
