{ stdenv, lib, fetchFromGitHub, autoreconfHook, python2, pkgconfig, libX11, libXext, glproto }:

let
  driverLink = "/run/opengl-driver" + lib.optionalString stdenv.isi686 "-32";
in stdenv.mkDerivation rec {
  name = "libglvnd-${version}";
  version = "2018-03-26";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "libglvnd";
    rev = "5baa1e5cfc422eb53e66f12ffb80c93d4a693cd9";
    sha256 = "13w9mdh14f3ramdpqj6h7sr7xd5gfkm79m46c7cdis6nniir7r9y";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig python2 ];
  buildInputs = [ libX11 libXext glproto ];

  NIX_CFLAGS_COMPILE = [
    "-UDEFAULT_EGL_VENDOR_CONFIG_DIRS"
    # FHS paths are added so that non-NixOS applications can find vendor files.
    "-DDEFAULT_EGL_VENDOR_CONFIG_DIRS=\"${driverLink}/share/glvnd/egl_vendor.d:/etc/glvnd/egl_vendor.d:/usr/share/glvnd/egl_vendor.d\""
  ];

  # Indirectly: https://bugs.freedesktop.org/show_bug.cgi?id=35268
  # configureFlags  = stdenv.lib.optionals stdenv.hostPlatform.isMusl [ "--disable-tls" "--disable-asm" ];

  outputs = [ "out" "dev" ];

  passthru = { inherit driverLink; };

  meta = with stdenv.lib; {
    description = "The GL Vendor-Neutral Dispatch library";
    homepage = https://github.com/NVIDIA/libglvnd;
    license = licenses.bsd2;
    platforms = platforms.linux;
  };
}
