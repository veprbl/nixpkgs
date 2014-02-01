{ stdenv, fetchurl, makeWrapper, wxGTK, gksu ? "" }:

stdenv.mkDerivation rec {
  name = "winusb-${version}";
  version = "1.0.11";

  src = fetchurl {
    url = "http://en.congelli.eu/directdl/winusb/winusb-${version}.tar.gz";
    sha256 = "1jbb0vas35arsikqw23wczhnv7pv123kbkrx2za4n4si6vkd5n3v";
  };

  buildInputs = [ makeWrapper wxGTK ];

  postInstall = ''
    # TODO: Package libgksu then gksu to make winusbgui work and then uncomment line below
    # https://projects.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/libgksu
    # https://projects.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/gksu
    #wrapProgram $out/bin/winusbgui --prefix PATH : ${gksu}/bin
  '';

  meta = with stdenv.lib; {
    homepage = http://congelli.eu/prog_info_winusb.html;
    description = ''
      A simple tool that enable you to create your own usb stick windows
      installer from an iso image or a real DVD
    '';
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
