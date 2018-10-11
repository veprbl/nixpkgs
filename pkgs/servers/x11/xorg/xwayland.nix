{ stdenv, fetchurl, wayland, wayland-protocols, xorgserver, xkbcomp, xkeyboard_config, epoxy, libxslt, libunwind, makeWrapper, meson, ninja, nettle }:

with stdenv.lib;

let
  xwayland_config_h_meson_in = fetchurl {
    name = "xwayland-config.h.meson.in";
    url = "https://cgit.freedesktop.org/xorg/xserver/plain/include/xwayland-config.h.meson.in?id=xorg-server-1.20.0";
    sha256 = "0gngampgls3qa2h745ndfavxw6r5x2lcrpylkyb4g5i2r1smpj29";
  };
in
xorgserver.overrideAttrs (oldAttrs: {

  name = "xwayland-${xorgserver.version}";
  propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [
    wayland wayland-protocols epoxy libxslt makeWrapper libunwind
    nettle /* sha1 */
  ];

  nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ meson ninja ];

  configureFlags = null;

  mesonFlags = [
    "-Dglamor=true"
    "-Dxwayland=true"
    "-Dxkb_bin_dir=${xkbcomp}/bin"
    "-Dxkb_dir=${xkeyboard_config}/etc/X11/xkb"
    "-Dxkb_output_dir=${placeholder "out"}/share/X11/xkb/compiled"
    "-Ddefault_font_path="

    "-Dxorg=false"
    "-Dxvfb=false"
    "-Dxnest=false"
    "-Dxquartz=false"
    "-Dxwin=false"
  ];

  # Add file missing from tarball
  postPatch = (oldAttrs.postPatch or "") + ''
    cp ${xwayland_config_h_meson_in} include/xwayland-config.h.meson.in
  '';

  postInstall = ''
    rm -fr $out/share/X11/xkb/compiled
  '';

  meta = {
    description = "An X server for interfacing X11 apps with the Wayland protocol";
    homepage = https://wayland.freedesktop.org/xserver.html;
    license = licenses.mit;
    platforms = platforms.linux;
  };
})
