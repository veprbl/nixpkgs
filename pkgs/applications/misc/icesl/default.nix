{ stdenv, lib, fetchzip, patchelf, freeglut, libX11, libICE, mesa, libSM, libXext }:
let
  lpath = stdenv.lib.makeLibraryPath [ libX11 freeglut libICE mesa libSM libXext ];
in
stdenv.mkDerivation rec {
  name = "iceSL-${version}";
  version = "2.1.10";

  src = fetchzip {
    url = "https://gforge.inria.fr/frs/download.php/file/37268/icesl${version}-amd64.zip";
    sha256 = "0dv3mq6wy46xk9blzzmgbdxpsjdaxid3zadfrysxlhmgl7zb2cn2";
  };

  installPhase = ''
    cp -r ./ $out
    chmod +x $out/bin/IceSL-slicer
    runHook postInstall 
  '';

  postInstall = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${lpath}" \
      $out/bin/IceSL-slicer

  '';

  meta = with lib; {
    description = "IceSL is a GPU-accelerated procedural modeler and slicer for 3D printing.";
    homepage = http://shapeforge.loria.fr/icesl/index.html;
    license = licenses.inria-icesl;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mgttlinger ];
  };
}
