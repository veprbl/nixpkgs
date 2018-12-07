{ stdenv, fetchurl, p7zip, autoPatchelfHook,
dbus, glib,  nss, nspr, gtk3, pango, atk, cairo, gdk_pixbuf,
libX11, libxcb, libXcomposite, libXext, libXfixes, libXi, libXrender,
libXtst, expat, libuuid, libXrandr, libXScrnSaver, alsaLib, cups, zlib }:

stdenv.mkDerivation rec {
  name = "trilium-${version}";
  version = "0.24.5";

  src = fetchurl {
    url = "https://github.com/zadam/trilium/releases/download/v${version}/trilium-linux-x64-${version}.7z";
    sha256 = "0dpkw875k941wkj14r3x86q15da3kjihb4lg4sjxbmhq2gv4jdjv";
  };

  nativeBuildInputs = [
    p7zip /* for unpacking */
    autoPatchelfHook
  ];

  buildInputs = [ stdenv.cc.cc
    dbus glib nss nspr gtk3 pango atk cairo gdk_pixbuf
    libX11 libxcb libXcomposite libXext libXfixes libXi libXrender
    libXtst expat libuuid libXrandr libXScrnSaver alsaLib cups zlib
  ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/usr/share/trilium

    cp -r ./* $out/usr/share/trilium
    ln -s $out/usr/share/trilium/trilium $out/bin/trilium

    find $out/usr/share -name "*-ia32-*" -print0 | xargs -0 rm -rf
  '';

  meta = with stdenv.lib; {
    description = "Trilium Notes is a hierarchical note taking application with focus on building large personal knowledge bases.";
    homepage = https://github.com/zadam/trilium;
    license = licenses.agpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ emmanuelrosa ];
  };
}
