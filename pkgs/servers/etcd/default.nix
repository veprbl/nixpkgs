{ stdenv, lib, libpcap, buildGoPackage, fetchFromGitHub }:

with lib;

buildGoPackage rec {
  name = "etcd-${version}";
  version = "3.0.15"; # After updating check that nixos tests pass

  goPackagePath = "github.com/coreos/etcd";

  src = fetchFromGitHub {
    owner = "coreos";
    repo = "etcd";
    rev = "v${version}";
    sha256 = "0kd1yxy57m4w86s6z97iy324kxxbk9caymd973xzz8hy0m36rw9f";
  };

  goDeps = ./deps.nix;

  buildInputs = [ libpcap ];

  meta = {
    description = "Distributed reliable key-value store for the most critical data of a distributed system";
    license = licenses.asl20;
    homepage = https://coreos.com/etcd/;
    maintainers = with maintainers; [offline];
    platforms = with platforms; linux;
  };
}
