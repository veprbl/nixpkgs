{ stdenv, fetchurl, makeWrapper, xorgserver, getopt
, xauth, utillinux, which, fontsConf, gawk, coreutils }:
let
  xvfb_run = fetchurl {
    url = https://salsa.debian.org/xorg-team/xserver/xorg-server/raw/9cad896318c78554d982f3d59f022c8ad87f7b61/debian/local/xvfb-run;
    sha256 = "1950na6k35d9rzyr9pd649plm70w70vz1840p623jz10wvwf01gx";
  };
in
stdenv.mkDerivation {
  name = "xvfb-run";
  buildInputs = [makeWrapper];
  buildCommand = ''
    mkdir -p $out/bin
    cp ${xvfb_run} $out/bin/xvfb-run

    chmod a+x $out/bin/xvfb-run
    patchShebangs $out/bin/xvfb-run
    wrapProgram $out/bin/xvfb-run \
      --set FONTCONFIG_FILE "${fontsConf}" \
      --prefix PATH : ${stdenv.lib.makeBinPath [ getopt xorgserver xauth which utillinux gawk coreutils ]}
  '';

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    license = licenses.gpl2;
  };
}
