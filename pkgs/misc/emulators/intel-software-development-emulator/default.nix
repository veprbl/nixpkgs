{ stdenv
, fetchurl
, libelf
, libdwarf
, patchelf
}:

let
  rpath = stdenv.lib.makeLibraryPath [ stdenv.cc.cc libelf libdwarf ];
in
  stdenv.mkDerivation rec {
    version = "8.12.0";
    name = "intel-software-development-emulator-${version}";

    src = fetchurl {
      url = "http://TODO-some-manual-prefetch-stuff-or-require-file.com/sde-external-8.12.0-2017-10-23-lin.tar.bz2";
      sha256 = "19xr1bgm9ij2fqr8l29vs7fk6pm1vmb9fxzj3k0rchm3k0znd4vd";
    };

    buildPhase = ''
      runHook preBuild
      find -type f -name "*.so" -exec patchelf --set-rpath "${rpath}" {} \;
      for f in sde64 xed64 intel64/nullapp intel64/pinbin; do
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                 --set-rpath "${rpath}" ./$f
      done 
      runHook postBuild
    '';

    dontPatchELF = true;

    installPhase = ''
      runHook preInstall
      rm -rf ia32 sde xed # Don't install anything 32-bit
      mkdir -p $out/share/intel-sde/
      cp -r ./ $out/share/intel-sde/
      mkdir -p $out/bin
      for p in sde64 xed64; do
        ln -sf $out/share/intel-sde/$p $out/bin
      done
      runHook postInstall
    '';

    meta = with stdenv.lib; {
      homepage = https://software.intel.com/en-us/articles/intel-software-development-emulator;
      description = "Intel® Software Development Emulator";
      platforms = platforms.linux;
      maintainers = with maintainers; [ knedlsepp ];
      license = licenses.unfree;
    };
  }
