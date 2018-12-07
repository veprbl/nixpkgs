{ stdenv, fetchurl, p7zip, autoPatchelfHook,
glib, gio, nss, nspr, gtk3, pango, atk, cairo, gdk_pixbuf,
libX11
gio-2.0.so.0 => not found
nss3.so => not found
nssutil3.so => not found
smime3.so => not found
nspr4.so => not found
gtk-3.so.0 => not found
gdk-3.so.0 => not found
pangocairo-1.0.so.0 => not found
pango-1.0.so.0 => not found
atk-1.0.so.0 => not found
cairo.so.2 => not found
gdk_pixbuf-2.0.so.0 => not found
X11.so.6 => not found
X11-xcb.so.1 => not found
xcb.so.1 => not found
Xcomposite.so.1 => not found
Xcursor.so.1 => not found
Xdamage.so.1 => not found
Xext.so.6 => not found
Xfixes.so.3 => not found
Xi.so.6 => not found
Xrender.so.1 => not found
Xtst.so.6 => not found
expat.so.1 => not found
uuid.so.1 => not found
Xrandr.so.2 => not found
Xss.so.1 => not found
asound.so.2 => not found
dbus-1.so.3 => not found
atk-bridge-2.0.so.0 => not found
m.so.6 => /nix/store/mrfcv8ipiksfdrx3xq7dvcrzgg2jdfsw-glibc-2.27/lib/libm.so.6
libcups.so.2 => not found
zlib }:

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

  buildInputs = [ stdenv.cc.cc ffmpeg zlib ];

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
