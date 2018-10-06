{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

with stdenv.lib;

buildGoPackage rec {
  name = "kind-${version}";
  version = "20181003-${stdenv.lib.strings.substring 0 7 rev}";
  rev = "2ae73f8ef93609991b0e47a67825390ceec95b3f";

  src = fetchFromGitHub {
    rev = rev;
    owner = "kubernetes-sigs";
    repo = "kind";
    sha256 = "0bg3y35sc1c73z4rfq11x1jz340786q91ywm165ri7vx280ffjgh";
  };

  goPackagePath = "sigs.k8s.io/kind";
  excludedPackages = "images/base/entrypoint";

  outputs = [ "bin" "out" ];

  meta = {
    description = "Kubernetes IN Docker - local clusters for testing Kubernetes";
    homepage = https://github.com/kubernetes-sigs/kind;
    maintainers = with stdenv.lib.maintainers; [ offline ];
    license = stdenv.lib.licenses.asl20;
  };
}
