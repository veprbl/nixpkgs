{ stdenv, fetchFromGitHub, makeWrapper, pythonPackages }:

stdenv.mkDerivation rec {
  name = "calico-containers-${version}";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "projectcalico";
    repo = "calico-containers";
    rev = "v${version}";
    sha256 = "154nsz032h0vhrcrgnqgzqg9kqjqny592dn5h520kghv4mpj0yrs";
  };

  buildInputs = [ makeWrapper pythonPackages.pycalico ];

  phases = ["unpackPhase" "installPhase"];

  installPhase = with pythonPackages; ''
    mkdir -p $out/bin $out/libexec/calico-containers
    cp -R calico_node calicoctl $out/libexec/calico-containers

    makeWrapper $out/libexec/calico-containers/calicoctl/calicoctl.py $out/bin/calicoctl \
      --set PYTHONPATH $PYTHONPATH:${docopt}/${python.sitePackages}:${netaddr}/${python.sitePackages}:${prettytable}/${python.sitePackages}:${docker}/${python.sitePackages}:${requests}/${python.sitePackages}:${six}/${python.sitePackages}:${websocket_client}/${python.sitePackages}:${python-etcd}/${python.sitePackages}:${urllib3}/${python.sitePackages}:${dns}/${python.sitePackages}
  '';

  meta = with stdenv.lib; {
    description = "Production-Grade Container Scheduling and Management";
    license = licenses.asl20;
    homepage = http://kubernetes.io;
    maintainers = with maintainers; [offline];
    platforms = [ "x86_64-linux" ];
  };
}
