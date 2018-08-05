{ fetchurl, stdenv, substituteAll, meson, ninja, pkgconfig, gnome3, glib, gtk, gsettings-desktop-schemas
, gnome-desktop, dbus, json-glib, libICE, xmlto, docbook_xsl, docbook_xml_dtd_412
, libxslt, gettext, makeWrapper, systemd, xorg, epoxy, gnugrep, bash }:

stdenv.mkDerivation rec {
  name = "gnome-session-${version}";
  version = "3.28.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-session/${gnome3.versionBranch version}/${name}.tar.xz";
    sha256 = "14nmbirgrp2nm16khbz109saqdlinlbrlhjnbjydpnrlimfgg4xq";
  };

  patches = [
    (substituteAll {
      src = ./fix-paths.patch;
      # FIXME: glib binaries shouldn't be in .dev!
      gsettings = "${glib.dev}/bin/gsettings";
      dbusLaunch = "${dbus.lib}/bin/dbus-launch";
      grep = "${gnugrep}/bin/grep";
      bash = "${bash}/bin/bash";
    })
  ];

  mesonFlags = [ "-Dsystemd=true" ];

  nativeBuildInputs = [
    meson ninja pkgconfig gettext makeWrapper
    xmlto libxslt docbook_xsl docbook_xml_dtd_412
    dbus # for DTD
  ];

  buildInputs = [
    glib gtk libICE gnome-desktop json-glib xorg.xtrans gnome3.defaultIconTheme
    gnome3.gnome-settings-daemon gsettings-desktop-schemas systemd epoxy
  ];

  # TODO: switch to substituteAll with placeholder
  # https://github.com/NixOS/nix/issues/1846
  # https://github.com/NixOS/nixpkgs/pull/37693
  postPatch = ''
    chmod +x meson_post_install.py # patchShebangs requires executable file
    patchShebangs meson_post_install.py


    substituteInPlace gnome-session/gsm-manager.c \
      --subst-var-by gschemasCompiled "$out/share/gsettings-schemas/${name}/glib-2.0/schemas"
    substituteInPlace gnome-session/gsm-session-save.c \
      --subst-var-by gschemasCompiled "$out/share/gsettings-schemas/${name}/glib-2.0/schemas"
    substituteInPlace tools/gnome-session-selector.c \
      --subst-var-by gschemasCompiled "$out/share/gsettings-schemas/${name}/glib-2.0/schemas"
  '';

  preFixup = ''
    for desktopFile in $(grep -rl "Exec=gnome-session" $out/share)
    do
      echo "Patching gnome-session path in: $desktopFile"
      sed -i "s,Exec=gnome-session,Exec=$out/bin/gnome-session," $desktopFile
    done
    wrapProgram "$out/bin/gnome-session" \
      --prefix GI_TYPELIB_PATH : "$GI_TYPELIB_PATH" \
      --suffix XDG_DATA_DIRS : "$out/share:$GSETTINGS_SCHEMAS_PATH" \
      --suffix XDG_DATA_DIRS : "${gnome3.gnome-shell}/share"\
      --suffix XDG_CONFIG_DIRS : "${gnome3.gnome-settings-daemon}/etc/xdg"
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = "gnome-session";
      attrPath = "gnome3.gnome-session";
    };
  };

  meta = with stdenv.lib; {
    description = "GNOME session manager";
    homepage = https://wiki.gnome.org/Projects/SessionManagement;
    license = licenses.gpl2Plus;
    maintainers = gnome3.maintainers;
    platforms = platforms.linux;
  };
}
