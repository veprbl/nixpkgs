{ stdenv, fetchFromGitHub, autoreconfHook, makeWrapper
, pkgconfig, dbus, dbus-glib, libxml2 }:

stdenv.mkDerivation rec {
  name = "thermald-${version}";
  version = "1.8.0.1"; # not really, git

  src = fetchFromGitHub {
    owner = "intel";
    repo = "thermal_daemon";
    #rev = "v${version}";
    rev = "39c51b19cf7c163fa5ae37b6e723d4756a25f18d";
    sha256 = "0877m4v326i2l6xwkq5jbcgl9zy9fi7nvvmncbc1c5kdgps6aq7r";
  };

  nativeBuildInputs = [ pkgconfig autoreconfHook makeWrapper ];
  buildInputs = [ dbus dbus-glib libxml2 ];

  configureFlags = [
    "--sysconfdir=$(out)/etc" "--localstatedir=/var"
    "--with-dbus-sys-dir=$(out)/etc/dbus-1/system.d"
    "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
    ];

  postInstall = ''
    mkdir -p $out/bin
    cp ./tools/thermald_set_pref.sh $out/bin/

    patchShebangs $out/bin/thermald_set_pref.sh
    wrapProgram $out/bin/thermald_set_pref.sh --prefix PATH ':' ${stdenv.lib.makeBinPath [ dbus ]}
  '';

  meta = with stdenv.lib; {
    description = "Thermal Daemon";
    homepage = https://01.org/linux-thermal-daemon;
    license = licenses.gpl2;
    platforms = [ "x86_64-linux" "i686-linux" ];
    maintainers = with maintainers; [ abbradar ];
  };
}
