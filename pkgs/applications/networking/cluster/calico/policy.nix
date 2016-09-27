{ stdenv, fetchFromGitHub, makeWrapper, pythonPackages }:

stdenv.mkDerivation rec {
  name = "calico-k8s-policy-${version}";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "projectcalico";
    repo = "k8s-policy";
    rev = "v${version}";
    sha256 = "0d5s966msyi9wznqhiyd8lg4ayh0nkrh1jn5nilin1bcd1ngi3mf";
  };

  buildInputs = with pythonPackages; [
    makeWrapper
    pycalico docopt netaddr prettytable docker requests six
    python-etcd urllib3 dns simplejson
  ];

  phases = ["unpackPhase" "installPhase"];

  installPhase = ''
    mkdir -p $out/bin $out/libexec/calico-policy
    cp -R . $out/libexec/calico-policy

    substituteInPlace $out/libexec/calico-policy/controller.py \
        --replace "/usr/bin/python" "${pythonPackages.python}/bin/python"
    chmod +x $out/libexec/calico-policy/controller.py
    makeWrapper $out/libexec/calico-policy/controller.py $out/bin/calico-k8s-policy \
      --set PYTHONPATH $PYTHONPATH
  '';

  meta = with stdenv.lib; {
    description = "Calico policy agent for Kubernetes";
    license = licenses.asl20;
    homepage = https://github.com/projectcalico/k8s-policy;
    maintainers = with maintainers; [offline];
    platforms = [ "x86_64-linux" ];
  };
}
