{ stdenv, fetchFromGitHub, autoreconfHook, makeWrapper
, pkgconfig, dbus, dbus-glib, libxml2 }:

stdenv.mkDerivation rec {
  name = "thermald-${version}";
  version = "1.8.0.1"; # not really, git

  src = fetchFromGitHub {
    owner = "intel";
    repo = "thermal_daemon";
    #rev = "v${version}";
    rev = "5c4aa87260803b5844212322f3459400eb8843d3";
    sha256 = "0mabg591d7cl5daw0csfbp80dnr99mi7s6phmvdc0nws0xcl4dhk";
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
