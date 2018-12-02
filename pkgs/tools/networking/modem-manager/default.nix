{ stdenv, fetchurl, glib, udev, libgudev, polkit, ppp, gettext, pkgconfig
, libmbim, libqmi, systemd, fetchpatch }:

stdenv.mkDerivation rec {
  name = "modem-manager-${version}";
  version = "1.7.990";

  package = "ModemManager";
  src = fetchurl {
    url = "https://www.freedesktop.org/software/${package}/${package}-${version}.tar.xz";
    sha256 = "1v4hixmghlrw7w4ajq2x4k62js0594h223d0yma365zwqr7hjrfl";
  };

  nativeBuildInputs = [ gettext pkgconfig ];

  buildInputs = [ glib udev libgudev polkit ppp libmbim libqmi systemd ];

  patches = [
    # Patch dependency on glib headers, this breaks packages using core headers (networkmanager-qt)
    (fetchpatch {
      url = "https://cgit.freedesktop.org/ModemManager/ModemManager/patch/?id=0f377f943eeb81472fd73189f2c3d8fc65b8c609";
      sha256 = "0av0sqdvbhwjnhqqylkc7rmqcj6awqmz5693l9x93nlwp7zya95j";
    })
  ];

  configureFlags = [
    "--with-polkit"
    "--with-udev-base-dir=$(out)/lib/udev"
    "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
    "--with-dbus-sys-dir=$(out)/etc/dbus-1/system.d"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-suspend-resume=systemd"
  ];

  postInstall = ''
    # systemd in NixOS doesn't use `systemctl enable`, so we need to establish
    # aliases ourselves.
    ln -s $out/etc/systemd/system/ModemManager.service \
      $out/etc/systemd/system/dbus-org.freedesktop.ModemManager1.service
  '';

  meta = with stdenv.lib; {
    description = "WWAN modem manager, part of NetworkManager";
    homepage = https://www.freedesktop.org/wiki/Software/ModemManager/;
    license = licenses.gpl2Plus;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
