{ stdenv, fetchurl, fetchgit, pkgconfig, libdrm, libpciaccess, cairo, pixman, udev, xorgproto
, libX11, libXext, libXv, libXrandr, glib, bison, libunwind, python3, kmod
, procps, utilmacros, gtk-doc, openssl, peg, meson, ninja, elfutils, flex }:

stdenv.mkDerivation rec {
  name = "intel-gpu-tools-${version}";
  version = "1.23-git";

  src = fetchgit {
    url = https://gitlab.freedesktop.org/drm/igt-gpu-tools;
    rev = "478615b1edba88559386ba80ccbf0f035f3360a9";
    sha256 = "0bwaqkn96dfrjiv3885wphia9j2gdnnlcpk8h7d95rcmjk1r3574";
  };
  #src = fetchurl {
  #  url = "https://xorg.freedesktop.org/archive/individual/app/igt-gpu-tools-${version}.tar.xz";
  #  sha256 = "1l4s95m013p2wvddwr4cjqyvsgmc88zxx2887p1fbb1va5n0hjsd";
  #};

  nativeBuildInputs = [ pkgconfig utilmacros meson ninja flex ];
  buildInputs = [ libdrm libpciaccess cairo pixman xorgproto udev libX11 kmod
    libXext libXv libXrandr glib bison libunwind python3 procps
    gtk-doc openssl peg elfutils ];

  #preConfigure = ''
  #  ./autogen.sh
  #'';

  mesonFlags = [ "-Dbuild_docs=false" ];

  postPatch = ''
    patchShebangs tests

    patchShebangs debugger/system_routine/pre_cpp.py
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = https://01.org/linuxgraphics/;
    description = "Tools for development and testing of the Intel DRM driver";
    license = licenses.mit;
    platforms = [ "x86_64-linux" "i686-linux" ];
    maintainers = with maintainers; [ pSub ];
  };
}
