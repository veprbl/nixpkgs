{ stdenv, fetchgit, fetchurl, writeScript
, libGL, libX11, libXext, python3, libXrandr, libXrender, libpulseaudio, libXcomposite
, enableGlfw ? false, glfw }:

let
  inherit (stdenv.lib) optional makeLibraryPath;

  # gl.xml
  gl = fetchurl {
    url = https://raw.githubusercontent.com/KhronosGroup/OpenGL-Registry/a24f3f7a4c924fdbc666024f99c70e5b8e34c819/xml/gl.xml;
    sha256 = "1mskxjmhb35m8qv255pibf633d8sn1w9rdsf0lj75bhlgy0zi5c7";
  };
  # EGL 1.5
  egl = fetchurl {
    url = https://www.khronos.org/registry/EGL/api/KHR/khrplatform.h;
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
in stdenv.mkDerivation rec {
  name = "wallama-paper-${version}";
  version = "2018-08-16";

  src = fetchgit {
    url = https://github.com/Aaahh/wallama-paper;
    rev = "d2feae0df470a5d1cafcf8487c3504a85a07452d";
    sha256 = "0angfyd04h40pj28badccpcq6ac1ymrrcsavw1w9s94sbviry6cw";
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

  prePatch = ''
    mkdir -p glad/include/KHR

    cp ${gl} glad/gl.xml
    cp ${egl} glad/include/KHR/khrplatform.h
    patchShebangs .
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
      An OpenGL wallpaper with audio spectrum visualizer functions
    '';
    homepage = https://github.com/Aaahh/wallama-paper;
    platforms = platforms.linux;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      eadwu
    ];
  };
}
