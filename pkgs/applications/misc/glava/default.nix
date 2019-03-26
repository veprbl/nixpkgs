{ stdenv, writeScript, fetchFromGitHub
, libGL, libX11, libXext, python3, libXrandr, libXrender, libpulseaudio, libXcomposite
, enableGlfw ? false, glfw, runtimeShell }:

let
  inherit (stdenv.lib) optional makeLibraryPath;

  #wrapperScript = writeScript "glava" ''
  #  #!${runtimeShell}
  #  case "$1" in
  #    --copy-config)
  #      # The binary would symlink it, which won't work in Nix because the
  #      # garbage collector will eventually remove the original files after
  #      # updates
  #      echo "Nix wrapper: Copying glava config to ~/.config/glava"
  #      cp -r --no-preserve=all @out@/etc/xdg/glava ~/.config/glava
  #      ;;
  #    *)
  #      exec @out@/bin/.glava-unwrapped "$@"
  #  esac
  #'';
in
  stdenv.mkDerivation rec {
    name = "glava-${version}";
    version = "1.6.3";

    src = fetchFromGitHub {
      owner = "wacossusca34";
      repo = "glava";
      rev = "v${version}";
      sha256 = "0kqkjxmpqkmgby05lsf6c6iwm45n33jk5qy6gi3zvjx4q4yzal1i";
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

    preConfigure = ''
      substituteInPlace Makefile \
        --replace 'unknown' 'v${version}'
    '';

    makeFlags = optional (!enableGlfw) "DISABLE_GLFW=1"
    ++ [
      "DESTDIR=/"
      "SHADERDIR=${placeholder "out"}/etc/xdg/glava"
      "EXECDIR=${placeholder "out"}/bin"
      "CFLAGS=-march=native" # XXX ?!
    ];

    fixupPhase = ''
      patchelf \
        --set-rpath "$(patchelf --print-rpath $out/bin/glava):${makeLibraryPath [ libGL ]}" \
        $out/bin/glava
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
