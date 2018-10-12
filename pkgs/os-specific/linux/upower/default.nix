{ stdenv, fetchgit, pkgconfig, dbus-glib
, intltool, libxslt, docbook_xsl, udev, libgudev, libusb1
, gtk-doc, automake, autoconf, libtool, which
, useSystemd ? true, systemd, gobjectIntrospection
}:

stdenv.mkDerivation rec {
  name = "upower-0.99.8-git";

  src = fetchgit {
    url = https://gitlab.freedesktop.org/upower/upower.git;
    rev = "0a9d9ab4949effb20e77aa52e7b4ee07e776fc0d";
    sha256 = "0jv6f71wqhlrz6n545p8zj5snvxx03sjllzia3vqiyijqkd21p80";
  };

  buildInputs =
    [ dbus-glib intltool libxslt docbook_xsl udev libgudev libusb1 gobjectIntrospection ]
    ++ stdenv.lib.optional useSystemd systemd;

  nativeBuildInputs = [ pkgconfig autoconf automake libtool which gtk-doc ];

  preConfigure = "NOCONFIGURE=1 ./autogen.sh";

  configureFlags =
    [ "--with-backend=linux" "--localstatedir=/var"
    ]
    ++ stdenv.lib.optional useSystemd
    [ "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
      "--with-systemdutildir=$(out)/lib/systemd"
      "--with-udevrulesdir=$(out)/lib/udev/rules.d"
    ];

  NIX_CFLAGS_LINK = "-lgcc_s";

  doCheck = false; # fails with "env: './linux/integration-test': No such file or directory"

  installFlags = "historydir=$(TMPDIR)/foo";

  meta = {
    homepage = https://upower.freedesktop.org/;
    description = "A D-Bus service for power management";
    platforms = stdenv.lib.platforms.linux;
    license = stdenv.lib.licenses.gpl2Plus;
  };
}
