{ stdenv, fetchurl, dpkg, autoPatchelfHook
, libX11, glib, xorg, fontconfig, freetype, alsaLib
, pango, cairo, atk, dbus, gtk2, gdk_pixbuf
, gnutls, nettle, librsvg
, fribidi
, libcef
, libunistring, avahi
, zlib, libpng12, libICE, libXrender, cups, nss, nspr }:

let
  bits = if stdenv.hostPlatform.system == "x86_64-linux" then "x86_64"
         else "x86";

  version = "11.1.0.8392";
in stdenv.mkDerivation rec{
  name = "wpsoffice-${version}";

  src = fetchurl {
    name = "${name}.deb";
    url = "http://kdl.cc.ksosoft.com/wps-community/download/8392/wps-office_${version}_amd64.deb";
    #url = "http://kdl.cc.ksosoft.com/wps-community/download/a21/wps-office_${version}~a21_${bits}.tar.xz";
    sha256 = if bits == "x86_64" then
      "0bvwnx85ph4m236s85iwqid5dvym21qcikr32r7c9kqr714njxgg" else
      "1111111111111111111111111111111111111111111111111111";
  };

  meta = {
    description = "Office program originally named Kingsoft Office";
    homepage = http://wps-community.org/;
    platforms = [ "i686-linux" "x86_64-linux" ];
    hydraPlatforms = [];
    license = stdenv.lib.licenses.unfreeRedistributable;
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook ];

  unpackPhase = "dpkg-deb -x $src .";

  runtimeDependencies = buildInputs;
  buildInputs = [
    alsaLib
    libX11
    xorg.libxcb
    xorg.libXau
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXdmcp
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXtst
    xorg.libSM
    libpng12
    glib
    fontconfig
    zlib
    freetype
    libICE
    cups.lib
    nss nspr
    pango cairo atk dbus gtk2 gdk_pixbuf
    librsvg
    fribidi
    libcef
    avahi
    libunistring
    gnutls nettle
    stdenv.cc.cc # libstdc++
  ];

  dontPatchELF = true;

  # wpsoffice uses `/build` in its own build system making nix things there
  # references to nix own build directory
  noAuditTmpdir = true;

  installPhase = ''
    mkdir -p $out
    mv usr/{share,bin} $out/
    mv opt $out/opt
    prefix=$out/opt/kingsoft/wps-office

    ## for i in wps wpp et wpsoffice; do
    ##   patchelf \
    ##     --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
    ##     --force-rpath --set-rpath "$prefix/office6:$libPath" \
    ##     $prefix/office6/$i
    ## done

    for i in wps wpp et; do
      substituteInPlace $out/bin/$i \
        --replace /opt/kingsoft/wps-office $prefix

      substituteInPlace $out/share/applications/wps-office-$i.desktop \
        --replace /usr/bin $out/bin
    done

    # :(
    rm $prefix/office6/libjs*

    # use ours
    rm $prefix/office6/libcef*

    ## # China fonts
    ## mkdir -p $prefix/resource/fonts/wps-office $out/etc/fonts/conf.d
    ## ln -s $prefix/fonts/* $prefix/resource/fonts/wps-office
    ## ln -s $prefix/fontconfig/*.conf $out/etc/fonts/conf.d

    ## ln -s $prefix/resource $out/share
  '';
}
