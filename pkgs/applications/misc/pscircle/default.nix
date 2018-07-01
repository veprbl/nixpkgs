{ stdenv, fetchFromGitLab, pkgconfig
, meson, ninja
, cairo, libpng
, otherImageFormats ? false, libX11 }:

let
  inherit (stdenv.lib) optional;

  version = "1.0.0";
in
  stdenv.mkDerivation rec {
    name = "pscircle-${version}";

    src = fetchFromGitLab {
      owner = "mildlyparallel";
      repo = "pscircle";
      rev = "v${version}";
      sha256 = "188d0db62215pycmx2qfmbbjpmih03vigsz2j448zhsbyxapavv3";
    };

    buildInputs = [
      cairo
      meson
      ninja
      libpng
    ] ++ optional otherImageFormats libX11;

    nativeBuildInputs = [
      pkgconfig
    ];

    mesonFlags = optional (!otherImageFormats) "-Denable-x11=false";

    meta = with stdenv.lib; {
      description = ''
        Visualizes Linux processes in a radial tree
      '';
      homepage = https://gitlab.com/mildlyparallel/pscircle;
      platforms = platforms.linux;
      license = licenses.gpl2;
      maintainers = with maintainers; [
        eadwu
      ];
    };
  }
