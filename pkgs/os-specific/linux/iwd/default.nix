{ stdenv, fetchgit, autoreconfHook, pkgconfig, coreutils, readline, python3Packages }:

let
  ell = fetchgit {
     url = https://git.kernel.org/pub/scm/libs/ell/ell.git;
     #rev = "0.17";
     rev = "6604930e7bd37468894a1cdd1475b2d7cd198c74"; # 2019-01-27
     sha256 = "1r2mlrcy1g4jxk1zqfm82nbhq2j2qmvi2slrqji397cbqvlfrd5r";
  };
in stdenv.mkDerivation rec {
  name = "iwd-${version}";
  #version = "0.14";
  version = "2019-01-25";

  src = fetchgit {
    url = https://git.kernel.org/pub/scm/network/wireless/iwd.git;
    rev = "e4f22f0a5d65886f93642688ac795388f02dd940";
    #rev = version;
    sha256 = "0w4ans7yvdyr1k3839xf3xg4sckrjlw7s56mgh6qhzws4snarqf1";
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
    "--with-dbus-datadir=$(out)/etc/"
    "--with-dbus-busdir=$(out)/usr/share/dbus-1/system-services/"
    "--with-systemd-unitdir=$(out)/lib/systemd/system/"
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
    substituteInPlace $out/usr/share/dbus-1/system-services/net.connman.ead.service \
                      --replace /bin/false ${coreutils}/bin/false
    substituteInPlace $out/usr/share/dbus-1/system-services/net.connman.iwd.service \
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
