{ stdenv, wayland, wayland-protocols, xorgserver, xkbcomp, xkeyboard_config, epoxy, libxslt, libunwind, makeWrapper, meson, ninja, nettle }:

with stdenv.lib;

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
  ];
  #configureFlags = [
  #  "--disable-docs"
  #  "--disable-devel-docs"
  #  "--enable-xwayland"
  #  "--disable-xorg"
  #  "--disable-xvfb"
  #  "--disable-xnest"
  #  "--disable-xquartz"
  #  "--disable-xwin"
  #  "--enable-glamor"
  #  "--with-default-font-path="
  #  "--with-xkb-bin-directory=${xkbcomp}/bin"
  #  "--with-xkb-path=${xkeyboard_config}/etc/X11/xkb"
  #  "--with-xkb-output=$(out)/share/X11/xkb/compiled"
  #];

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
