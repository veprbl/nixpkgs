{ stdenv, fetchurl, pkgconfig, openconnect, file, gawk,
  openvpn, vpnc, glib, dbus, iptables, gnutls, polkit,
  wpa_supplicant ? null, enableWPASupplicant ? false,
  readline80, pptp, ppp }:

stdenv.mkDerivation rec {
  name = "connman-${version}";
  version = "1.37";
  src = fetchurl {
    url = "mirror://kernel/linux/network/connman/${name}.tar.xz";
    sha256 = "05kfjiqhqfmbbwc4snnyvi5hc4zxanac62f6gcwaf5mvn0z9pqkc";
  };

  buildInputs = [ openconnect polkit
                  openvpn vpnc glib dbus iptables gnutls
                  readline80 pptp ppp ] ++ stdenv.lib.optional enableWPASupplicant wpa_supplicant;

  nativeBuildInputs = [ pkgconfig file gawk ];

  preConfigure = stdenv.lib.optionalString enableWPASupplicant ''
    export WPASUPPLICANT=${wpa_supplicant}/sbin/wpa_supplicant
  '' + ''
    export PPPD=${ppp}/sbin/pppd
    export AWK=${gawk}/bin/gawk
    substituteInPlace configure --replace /usr/bin/file file
  '';

  configureFlags = [
    "--sysconfdir=${placeholder "out"}/etc"
    "--localstatedir=/var"
    "--with-dbusconfdir=${placeholder "out"}/etc"
    "--with-dbusdatadir=${placeholder "out"}/usr/share"
    "--disable-maintainer-mode"
    "--enable-openconnect=builtin"
    "--with-openconnect=${openconnect}/sbin/openconnect"
    "--enable-openvpn=builtin"
    "--with-openvpn=${openvpn}/sbin/openvpn"
    "--enable-vpnc=builtin"
    "--with-vpnc=${vpnc}/sbin/vpnc"
    "--enable-session-policy-local=builtin"
    "--enable-client"
    "--enable-bluetooth"
    "--enable-wifi"
    "--enable-polkit"
    "--enable-tools"
    "--enable-datafiles"
    "--enable-pptp"
    "--with-pptp=${pptp}/sbin/pptp"
    "--enable-iwd"
  ];

  postInstall = ''
    cp ./client/connmanctl $out/sbin/connmanctl
  '';

  meta = with stdenv.lib; {
    description = "A daemon for managing internet connections";
    homepage = https://01.org/connman;
    maintainers = [ maintainers.matejc ];
    platforms = platforms.linux;
    license = licenses.gpl2;
  };
}
