{ stdenv, fetchurl, fetchFromGitHub, fetchpatch, substituteAll, intltool, pkgconfig, dbus, dbus-glib, gtk-doc, perl
, gnome3, systemd, libuuid, polkit, gnutls, ppp, dhcp, iptables
, libgcrypt, dnsmasq, bluez5, readline, libpsl
, gobject-introspection, modemmanager, openresolv, libndp, newt, libsoup
, ethtool, gnused, coreutils, file, iputils, kmod, jansson, libxslt
, python3Packages, docbook_xsl, openconnect, curl, autoreconfHook }:

let
  pname = "NetworkManager";
in stdenv.mkDerivation rec {
  name = "network-manager-${version}";
  version = "1.17.90"; # 1.18-rc1

  #src = fetchurl {
  #  url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
  #  sha256 = "149gchck86ypp2pr836mgcm18ginrbinfgdw4h7n9zi9rab6r32c";
  #};
  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    #rev = "549112c1ba5306dff281ef0788961ac855342d02";
    rev = "5fbd3d4e452409b8c98bf71de521cdedc7cce2d9";
    sha256 = "04cfnjwsp0p5yxdvyij3aqrirk9a47fs3yzbd92hn0c6bjb74nm5";
  };

  outputs = [ "out" "dev" ];

  postPatch = ''
    patchShebangs ./tools
    chmod +x libnm/*.py
    chmod +x libnm/*.pl
    patchShebangs libnm/*.py
    patchShebangs libnm/*.pl
  '';

  preConfigure = ''
    substituteInPlace configure --replace /usr/bin/uname ${coreutils}/bin/uname
    substituteInPlace configure --replace /usr/bin/file ${file}/bin/file

    # Fixes: error: po/Makefile.in.in was not created by intltoolize.
    intltoolize --automake --copy --force
  '';

  # Right now we hardcode quite a few paths at build time. Probably we should
  # patch networkmanager to allow passing these path in config file. This will
  # remove unneeded build-time dependencies.
  configureFlags = [
    "--with-dhclient=${dhcp}/bin/dhclient"
    "--with-dnsmasq=${dnsmasq}/bin/dnsmasq"
    # Upstream prefers dhclient, so don't add dhcpcd to the closure
    "--with-dhcpcd=no"
    "--with-pppd=${ppp}/bin/pppd"
    "--with-iptables=${iptables}/bin/iptables"
    # to enable link-local connections
    "--with-udev-dir=${placeholder "out"}/lib/udev"
    "--with-resolvconf=${openresolv}/sbin/resolvconf"
    "--sysconfdir=/etc" "--localstatedir=/var"
    "--with-dbus-sys-dir=${placeholder "out"}/etc/dbus-1/system.d"
    "--with-crypto=gnutls" "--disable-more-warnings"
    "--with-systemdsystemunitdir=${placeholder "out"}/etc/systemd/system"
    "--with-kernel-firmware-dir=/run/current-system/firmware"
    "--with-session-tracking=systemd"
    "--with-modem-manager-1"
    "--with-nmtui"
    "--with-iwd"
    #"--disable-gtk-doc"
    #"--with-libnm-glib" # legacy library, TODO: remove
    "--disable-tests"
    #"--with-ebpf=yes"
  ];

  patches = [
    (substituteAll {
      src = ./fix-paths.patch;
      inherit iputils kmod openconnect ethtool coreutils dbus;
      inherit (stdenv) shell;
    })
  ];

  buildInputs = [
    systemd libuuid polkit ppp libndp curl libpsl
    bluez5 dnsmasq gobject-introspection modemmanager readline newt libsoup jansson
  ];

  propagatedBuildInputs = [ dbus-glib gnutls libgcrypt python3Packages.pygobject3 ];

  nativeBuildInputs = [ autoreconfHook intltool pkgconfig libxslt docbook_xsl gtk-doc perl ];

  autoreconfPhase = ''
    NOCONFIGURE=1 ./autogen.sh
  '';

  preBuild= ''
    echo "Generating config-extra.h.."
    make config-extra.h
    echo "Running: make install-libLTLIBRARIES $installFlags"
    make install-libLTLIBRARIES $installFlags -j$NIX_BUILD_CORES
  '';

  doCheck = false; # requires /sys, the net

  installFlags = [
    "sysconfdir=${placeholder "out"}/etc"
    "localstatedir=${placeholder "out"}/var"
    "runstatedir=${placeholder "out"}/var/run"
  ];

  enableParallelBuilding = true;

  postInstall = ''
    mkdir -p $out/lib/NetworkManager

    # FIXME: Workaround until NixOS' dbus+systemd supports at_console policy
    substituteInPlace $out/etc/dbus-1/system.d/org.freedesktop.NetworkManager.conf --replace 'at_console="true"' 'group="networkmanager"'

    # systemd in NixOS doesn't use `systemctl enable`, so we need to establish
    # aliases ourselves.
    ln -s $out/etc/systemd/system/NetworkManager-dispatcher.service $out/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
    ln -s $out/etc/systemd/system/NetworkManager.service $out/etc/systemd/system/dbus-org.freedesktop.NetworkManager.service

    # Add the legacy service name from before #51382 to prevent NetworkManager
    # from not starting back up:
    # TODO: remove this once 19.10 is released
    ln -s $out/etc/systemd/system/NetworkManager.service $out/etc/systemd/system/network-manager.service
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "networkmanager";
    };
  };

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Projects/NetworkManager;
    description = "Network configuration and management tool";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ phreedom rickynils domenkozar obadz ];
    platforms = platforms.linux;
  };
}
