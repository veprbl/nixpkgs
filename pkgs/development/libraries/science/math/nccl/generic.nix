{ version
, srcName
, sha256
}:

{ stdenv
, lib
, requireFile
, cudatoolkit
}:

stdenv.mkDerivation rec {
  name = "cudatoolkit-${cudatoolkit.majorVersion}-nccl-${version}";

  inherit version;

  src = requireFile rec {
    name = srcName;
    inherit sha256;
    message = ''
      This nix expression requires that ${name} is already part of the store.
      Register yourself to NVIDIA Accelerated Computing Developer Program, retrieve the NCCL library
      at https://developer.nvidia.com/nccl, and run the following command in the download directory:
      nix-prefetch-url file://${name}
    '';
  };

  propagatedBuildInputs = [
    cudatoolkit
  ];

  unpackPhase = ''
    tar xvf $src
  '';

  installPhase = ''
    function fixRunPath {
      p=$(patchelf --print-rpath $1)
      patchelf --set-rpath "$p:${lib.makeLibraryPath [ stdenv.cc.cc ]}" $1
    }
    fixRunPath nccl_${version}+cuda${cudatoolkit.majorVersion}_x86_64/lib/libnccl.so

    mkdir -p $out
    cp -a nccl_${version}+cuda${cudatoolkit.majorVersion}_x86_64/include $out/include
    cp -a nccl_${version}+cuda${cudatoolkit.majorVersion}_x86_64/lib $out/lib
    ln -s lib $out/lib64
  '';

  meta = with stdenv.lib; {
    description = ''
      NVIDIA Collective Communications Library.
      Multi-GPU and multi-node collective communication primitives.
    '';
    homepage = https://developer.nvidia.com/nccl;
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ hyphon81 ];
  };
}
