{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "echoip-${version}";
  version = "unstable-2019-04-27";

  src = fetchFromGitHub {
    owner = "mpolden";
    repo = "echoip";
    rev = "27fa828efb9034f359f638d29eda1f84aa08cc48";
    sha256 = "1rp2vgpfc514qgq715rkhhiciz6k8ms19qs31q1an3aapacf446p";
  };

  modSha256 = "025p891klwpid5fw4z39fimgfkwgkcwqpn5276hflzdp1hfv35ly";

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
