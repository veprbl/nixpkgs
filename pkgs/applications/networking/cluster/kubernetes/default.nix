{ stdenv, lib, fetchFromGitHub, which, go, makeWrapper, rsync
, iptables, coreutils
, components ? [
    "cmd/kubectl"
    "cmd/hyperkube"
    "cmd/kube-dns"
  ]
}:

with lib;

stdenv.mkDerivation rec {
  name = "kubernetes-${version}";
  version = "1.3.5";

  src = fetchFromGitHub {
    owner = "kubernetes";
    repo = "kubernetes";
    rev = "v${version}";
    sha256 = "028a67760il768r316b2qsc20hjkch0xm0aaj2x2h09ja5c2zfbc";
  };

  buildInputs = [ makeWrapper which go rsync ];

  outputs = ["out" "man""pause"];

  postPatch = ''
    mkdir -p $(pwd)/Godeps/_workspace/src/k8s.io
    ln -s $(pwd) $(pwd)/Godeps/_workspace/src/k8s.io/kubernetes
    substituteInPlace "hack/lib/golang.sh" --replace "_cgo" ""
    patchShebangs ./hack
  '';

  buildPhase = ''
    GOPATH=$(pwd):$(pwd)/Godeps/_workspace

    GOLDFLAGS="-s" hack/build-go.sh --use_go_build ${concatStringsSep " " components}
    (cd build/pause && gcc pause.c -o pause)
  '';

  installPhase = ''
    mkdir -p "$out/bin" "$man/share/man" "$pause/bin"

    cp _output/local/go/bin/* "$out/bin/"
    cp build/pause/pause "$pause/bin/pause"
    cp -R docs/man/man1 "$man/share/man"
  '';

  preFixup = ''
    wrapProgram "$out/bin/hyperkube" --prefix PATH : "${iptables}/bin:${coreutils}/bin"

    # Remove references to go compiler
    while read file; do
      cat $file | sed "s,${go},$(echo "${go}" | sed "s,$NIX_STORE/[^-]*,$NIX_STORE/eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee,"),g" > $file.tmp
      mv $file.tmp $file
      chmod +x $file
    done < <(find $out/bin $pause/bin -type f 2>/dev/null)
  '';

  meta = {
    description = "Production-Grade Container Scheduling and Management";
    license = licenses.asl20;
    homepage = http://kubernetes.io;
    maintainers = with maintainers; [offline];
    platforms = platforms.linux;
  };
}
