{ stdenv, fetchgit, autoreconfHook, pkgconfig, coreutils, readline, python3Packages }:

let
  ell = fetchgit {
     url = https://git.kernel.org/pub/scm/libs/ell/ell.git;
     #rev = "0.17";
     rev = "4c220dca8c7b13774a7af5cd7a3ed06ef4d88a73"; # 2019-03-05
     sha256 = "1h12gzmvpsnjd32l4gl7algsmlnwhp287smm2knxbba7z9zii2ly";
  };
in stdenv.mkDerivation rec {
  name = "iwd-${version}";

  #version = "0.14";
  version = "2019-03-05";

  src = fetchgit {
    url = https://git.kernel.org/pub/scm/network/wireless/iwd.git;
    rev = "ef06f06cfb2168b6b2cf4371949a981378989f07";
    #rev = version;
    sha256 = "036nin1gz2wvvya1cy7bwpgpyvp0ajvirlbljr6c02srfppva717";
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
