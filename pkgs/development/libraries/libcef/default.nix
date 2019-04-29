{ stdenv, fetchurl, cmake, alsaLib, atk, cairo, cups, dbus, expat, fontconfig
, GConf, gdk_pixbuf, glib, gtk2, libX11, libxcb, libXcomposite, libXcursor
, libXdamage, libXext, libXfixes, libXi, libXrandr, libXrender, libXScrnSaver
, libXtst, nspr, nss, pango, libpulseaudio, systemd }:

let
  libPath =
    stdenv.lib.makeLibraryPath [
      alsaLib atk cairo cups dbus expat fontconfig GConf gdk_pixbuf glib gtk2
      libX11 libxcb libXcomposite libXcursor libXdamage libXext libXfixes libXi
      libXrandr libXrender libXScrnSaver libXtst nspr nss pango libpulseaudio
      systemd
    ];
in
stdenv.mkDerivation rec {
  name = "cef-binary-${version}";
  version = "3.3683.1920.g9f41a27";
  src = fetchurl {
    url = "http://opensource.spotify.com/cefbuilds/cef_binary_${version}_linux64.tar.bz2";
    sha256 = "12iv798p6g17jqxx4fid4jgwkrpvlfkx4250lk8byhync53zbw0d";
  };
  nativeBuildInputs = [ cmake ];
  makeFlags = "libcef_dll_wrapper";
  dontStrip = true;
  dontPatchELF = true;
  installPhase = ''
    mkdir -p $out/lib/ $out/share/cef/
    cp libcef_dll_wrapper/libcef_dll_wrapper.a $out/lib/
    cp ../Release/libcef.so $out/lib/
    patchelf --set-rpath "${libPath}" $out/lib/libcef.so
    cp ../Release/*.bin $out/share/cef/
    cp -r ../Resources/* $out/share/cef/
    cp -r ../include $out/
  '';

  meta = with stdenv.lib; {
    description = "Simple framework for embedding Chromium-based browsers in other applications";
    homepage = http://opensource.spotify.com/cefbuilds/index.html;
    maintainers = with maintainers; [ puffnfresh ];
    license = licenses.bsd3;
    platforms = with platforms; linux;
  };
}
