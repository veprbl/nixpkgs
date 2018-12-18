{ stdenv, fetchurl, p7zip, autoPatchelfHook, atomEnv, makeWrapper }:

stdenv.mkDerivation rec {
  name = "trilium-${version}";
  version = "0.26.0-beta";

  src = fetchurl {
    url = "https://github.com/zadam/trilium/releases/download/v${version}/trilium-linux-x64-${version}.7z";
    sha256 = "09fp6mfcm4smjlm2z44zb84w9gd77953i4fq72ld4hccw2kr6l51";
  };

  nativeBuildInputs = [
    p7zip /* for unpacking */
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = atomEnv.packages;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/trilium

    cp -r ./* $out/share/trilium
    ln -s $out/share/trilium/trilium $out/bin/trilium
  '';


  # This "shouldn't" be needed, remove when possible :)
  preFixup = ''
    wrapProgram $out/bin/trilium --prefix LD_LIBRARY_PATH : "${atomEnv.libPath}"
  '';

  dontStrip = true;

  meta = with stdenv.lib; {
    description = "Trilium Notes is a hierarchical note taking application with focus on building large personal knowledge bases.";
    homepage = https://github.com/zadam/trilium;
    license = licenses.agpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
