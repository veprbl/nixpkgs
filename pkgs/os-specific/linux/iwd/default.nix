{ stdenv, fetchgit, autoreconfHook, pkgconfig, coreutils, readline, python3Packages }:

let
  ell = fetchgit {
     url = https://git.kernel.org/pub/scm/libs/ell/ell.git;
     #rev = "0.17";
     rev = "06dc541f8b04766f8a7fac36e075a9427269e28a"; # 2019-02-21
     sha256 = "04jn31b4gqrvjkagyxna9innd0x7mwkz16q7warl1gdxl8wxhvji";
  };
in stdenv.mkDerivation rec {
  name = "iwd-${version}";

  #version = "0.14";
  version = "2019-02-20";

  src = fetchgit {
    url = https://git.kernel.org/pub/scm/network/wireless/iwd.git;
    rev = "7b3831515a729698d2d423394527002c41023dba";
    #rev = version;
    sha256 = "078yfmp0d7aj1b9lq4q04801z805dp244l7x8d2idxv7h8kp52wz";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkgconfig
    python3Packages.wrapPython
  ];

  buildInputs = [
    readline
    python3Packages.python
  ];

  pythonPath = [
    python3Packages.dbus-python
    python3Packages.pygobject3
  ];

  configureFlags = [
    "--with-dbus-datadir=${placeholder "out"}/etc/"
    "--with-dbus-busdir=${placeholder "out"}/share/dbus-1/system-services/"
    "--with-systemd-unitdir=${placeholder "out"}/lib/systemd/system/"
    "--with-systemd-modloaddir=${placeholder "out"}/etc/modules-load.d/" # maybe
    "--localstatedir=/var/"
    "--enable-wired"
  ];

  postUnpack = ''
    ln -s ${ell} ell
    patchShebangs .
  '';

  postInstall = ''
    cp -a test/* $out/bin/
    mkdir -p $out/share
    cp -a doc $out/share/
    cp -a README AUTHORS TODO $out/share/doc/
  '';

  preFixup = ''
    wrapPythonPrograms
  '';

  postFixup = ''
    substituteInPlace $out/share/dbus-1/system-services/net.connman.ead.service \
                      --replace /bin/false ${coreutils}/bin/false
    substituteInPlace $out/share/dbus-1/system-services/net.connman.iwd.service \
                      --replace /bin/false ${coreutils}/bin/false
  '';

  meta = with stdenv.lib; {
    homepage = https://git.kernel.org/pub/scm/network/wireless/iwd.git;
    description = "Wireless daemon for Linux";
    license = licenses.lgpl21;
    platforms = platforms.linux;
    maintainers = [ maintainers.mic92 ];
  };
}
