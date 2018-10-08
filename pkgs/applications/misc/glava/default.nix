{ stdenv, fetchgit, fetchurl, writeScript
, libGL, libX11, libXext, python3, libXrandr, libXrender, libpulseaudio, libXcomposite
, enableGlfw ? false, glfw }:

let
  inherit (stdenv.lib) optional makeLibraryPath;

  # gl.xml
  gl = fetchurl {
    url = "https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/f902fae4117105795d0b35313b92595a9b48f9fd/xml/gl.xml";
    sha256 = "13dsi2h5wmy3kdvflxgr93vd9lq7bpqdhb4ikbf5wfxxdg49g7px";
  };
  # EGL 1.5
  egl = fetchurl {
    url = "https://www.khronos.org/registry/EGL/api/KHR/khrplatform.h";
    sha256 = "0p0vs4siiya05cvbqq7cw3ci2zvvlfh8kycgm9k9cwvmrkj08349";
  };

  wrapperScript = writeScript "glava" ''
    #!${stdenv.shell}
    case "$1" in
      --copy-config)
        # The binary would symlink it, which won't work in Nix because the
        # garbage collector will eventually remove the original files after
        # updates
        echo "Nix wrapper: Copying glava config to ~/.config/glava"
        cp -r --no-preserve=all @out@/etc/xdg/glava ~/.config/glava
        ;;
      *)
        exec @out@/bin/.glava-unwrapped "$@"
    esac
  '';
in
  stdenv.mkDerivation rec {
    name = "glava-${version}";
    version = "1.5.3";

    src = fetchgit {
      url = "https://github.com/wacossusca34/glava.git";
      rev = "v${version}";
      sha256 = "1jmkz26irvp34r24g1zs2c05jyxfxyxgk2fi5hj62m2iqk3c9y0r";
    };

    buildInputs = [
      libX11
      libXext
      libXrandr
      libXrender
      libpulseaudio
      libXcomposite
    ] ++ optional enableGlfw glfw;

    nativeBuildInputs = [
      python3
    ];

    patchPhase = ''
      mkdir -p glad/include/KHR

      cp ${gl} glad/gl.xml
      cp ${egl} glad/include/KHR/khrplatform.h
      patchShebangs .
    '';

    preConfigure = ''
      export CFLAGS="-march=native"
    '';

    makeFlags = optional (!enableGlfw) "DISABLE_GLFW=1";

    installFlags = [
      "DESTDIR=$(out)"
    ];

    fixupPhase = ''
      mkdir -p $out/bin
      mv $out/usr/bin/glava $out/bin/.glava-unwrapped
      rm -rf $out/usr

      patchelf \
        --set-rpath "$(patchelf --print-rpath $out/bin/.glava-unwrapped):${makeLibraryPath [ libGL ]}" \
        $out/bin/.glava-unwrapped

      substitute ${wrapperScript} $out/bin/glava --subst-var out
      chmod +x $out/bin/glava
    '';

    meta = with stdenv.lib; {
      description = ''
        OpenGL audio spectrum visualizer
      '';
      homepage = https://github.com/wacossusca34/glava;
      platforms = platforms.linux;
      license = licenses.gpl3;
      maintainers = with maintainers; [
        eadwu
      ];
    };
  }
