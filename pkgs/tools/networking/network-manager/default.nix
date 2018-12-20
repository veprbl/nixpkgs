{ stdenv, fetchurl, fetchpatch, fetchFromGitHub, substituteAll, intltool, pkgconfig, dbus-glib, dbus
, gnome3, systemd, libuuid, polkit, gnutls, ppp, dhcp, iptables
, libgcrypt, dnsmasq, bluez5, readline
, gobject-introspection, modemmanager, openresolv, libndp, newt, libsoup
, ethtool, gnused, coreutils, file, inetutils, kmod, jansson, libxslt
, python3Packages, docbook_xsl, openconnect, curl, autoconf, automake, libtool, gtk-doc }:

let
  pname = "NetworkManager";
in stdenv.mkDerivation rec {
  name = "network-manager-${version}";
  version = "1.14.5-git";

  #src = fetchurl {
  #  url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
  #  sha256 = "064cgj9za0kzarks0lrv0qw2ysdphb5l97iw0c964bfiqzjfv8rm";
  #};
  src = fetchFromGitHub {
    owner = "NetworkManager";
    repo = "NetworkManager";
    rev = "1445b5b2966db464ca1a2f164a49cebaacf9e68c";
    sha256 = "0ia9ix715cgmp7pqn82kh2q8zclmf1y0abxd3pyhcbq4iaba4l6i";
  };

  outputs = [ "out" "dev" ];

  postPatch = ''
    patchShebangs ./tools
  '';

  preConfigure = ''
    for x in data/*.rules data/*.in; do
      substituteInPlace "$x" \
        --replace /bin/sh ${stdenv.shell} \
        --replace /usr/sbin/ethtool ${ethtool}/sbin/ethtool \
        --replace "'ethtool " "'${ethtool}/sbin/ethtool " \
        --replace /bin/sed ${gnused}/bin/sed \
        --replace "| sed " "| ${gnused}/bin/sed " \
        --replace /bin/kill ${coreutils}/bin/kill \
        --replace /usr/bin/dbus-send ${dbus}/bin/dbus-send
    done
    # to enable link-local connections
    configureFlags="$configureFlags --with-udev-dir=$out/lib/udev"

    # Fixes: error: po/Makefile.in.in was not created by intltoolize.
    #intltoolize --automake --copy --force

    NOCONFIGURE=1 ./autogen.sh

    substituteInPlace configure --replace /usr/bin/uname ${coreutils}/bin/uname
    substituteInPlace configure --replace /usr/bin/file ${file}/bin/file

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
    #"--with-udev-dir=$(out)/lib/udev"
    "--with-resolvconf=${openresolv}/sbin/resolvconf"
    "--sysconfdir=/etc" "--localstatedir=/var"
    "--with-dbus-sys-dir=\${out}/etc/dbus-1/system.d"
    "--with-crypto=gnutls" "--disable-more-warnings"
    "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
    "--with-kernel-firmware-dir=/run/current-system/firmware"
    "--with-session-tracking=systemd"
    "--with-modem-manager-1"
    "--with-nmtui"
    #"--disable-gtk-doc"
    "--enable-gtk-doc"
    "--with-libnm-glib" # legacy library, TODO: remove
    "--disable-tests"
  ];

  patches = [
    # https://bugzilla.gnome.org/show_bug.cgi?id=796751
    (fetchpatch {
      url = https://bugzilla.gnome.org/attachment.cgi?id=372953;
      sha256 = "0xg7bzs6dvkbv2qp67i7mi1c5yrmfd471xgmlkn15b33pqkzy3mc";
    })
    (substituteAll {
      src = ./fix-paths.patch;
      inherit inetutils kmod openconnect;
    })

  ];

  buildInputs = [
    systemd libuuid polkit ppp libndp curl
    bluez5 dnsmasq gobject-introspection modemmanager readline newt libsoup jansson
  ];

  propagatedBuildInputs = [ dbus-glib gnutls libgcrypt python3Packages.pygobject3 ];

  nativeBuildInputs = [ autoconf automake libtool intltool pkgconfig libxslt docbook_xsl gtk-doc ];

  doCheck = false; # requires /sys, the net

  preInstall = ''
    installFlagsArray=( "sysconfdir=$out/etc" "localstatedir=$out/var" "runstatedir=$out/var/run" )
  '';

  postInstall = ''
    mkdir -p $out/lib/NetworkManager

    # FIXME: Workaround until NixOS' dbus+systemd supports at_console policy
    substituteInPlace $out/etc/dbus-1/system.d/org.freedesktop.NetworkManager.conf --replace 'at_console="true"' 'group="networkmanager"'

    # rename to network-manager to be in style
    mv $out/etc/systemd/system/NetworkManager.service $out/etc/systemd/system/network-manager.service

    # systemd in NixOS doesn't use `systemctl enable`, so we need to establish
    # aliases ourselves.
    ln -s $out/etc/systemd/system/NetworkManager-dispatcher.service $out/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service
    ln -s $out/etc/systemd/system/network-manager.service $out/etc/systemd/system/dbus-org.freedesktop.NetworkManager.service
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
