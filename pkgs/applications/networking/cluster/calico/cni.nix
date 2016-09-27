{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "calico-cni-${version}";
  version = "1.4.0-rc3";

  src = fetchFromGitHub {
    owner = "projectcalico";
    repo = "calico-cni";
    rev = "v${version}";
    sha256 = "1a67zfqgl2ngpbfqzafvwrd0s5gwyba39ifr5j5vp93xkv1ckn98";
  };

  outputs = ["out" "bin" "plugins"];

  goPackagePath = "github.com/calico-cni";
  goDeps = ./deps.json;

  # Remove vendor folders
  preBuild = ''find go/src -type d -name 'vendor' -prune -exec rm -r {} \;'';

  # Install plugins to plugins output needed by cni nixos module
  postFixup = ''
    mkdir $plugins
    mv $bin/bin/calico-cni $plugins/calico
    mv $bin/bin/ipam $plugins/calico-ipam
  '';

  meta = with stdenv.lib; {
    description = "Calico CNI plugin";
    license = licenses.asl20;
    homepage = https://www.projectcalico.org/;
    maintainers = with maintainers; [offline];
    platforms = [ "x86_64-linux" ];
  };
}
