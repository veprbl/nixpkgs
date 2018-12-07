{ stdenv, fetchurl, p7zip }:

stdenv.mkDerivation rec {
  name = "trilium-${version}";
  version = "0.24.5";

  phases = [ "unpackPhase" "installPhase" ];

  src = fetchurl {
    url = "https://github.com/zadam/trilium/releases/download/v${version}/trilium-linux-x64-${version}.7z";
    sha256 = "0dpkw875k941wkj14r3x86q15da3kjihb4lg4sjxbmhq2gv4jdjv";
  };

  nativeBuildInputs = [ p7zip /* for unpacking */ ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/usr/share/trilium

    cp -r ./* $out/usr/share/trilium
    ln -s $out/usr/share/trilium/trilium $out/bin/trilium
  '';

  meta = with stdenv.lib; {
    description = "Trilium Notes is a hierarchical note taking application with focus on building large personal knowledge bases.";
    homepage = https://github.com/zadam/trilium;
    license = licenses.agpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
