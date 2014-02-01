{ stdenv, fetchgit, autoconf, automake, pkgconfig,
  libbitcoin, obelisk, ncurses
}:

let version = "93fec48485"; in

stdenv.mkDerivation {
  name = "sx-${version}";

  src = fetchgit {
    url = "https://github.com/spesmilo/sx.git";
    rev = "93fec48485f5cdfa3ba336caf532964f20160eec";
    sha256 = "1cqrz36cq8q3fprxjdkklsdydpy4kq0w4l3nj8q8arxn706l38z8";
  };

  buildInputs = [ libbitcoin obelisk ncurses ];
  nativeBuildInputs = [ autoconf automake pkgconfig pythonPackages.wrapPython ];

  preConfigure = "autoreconf -i";
  postFixup = ''
    sed -i "$i" -e "1 s^.*/usr/bin[ ]*python^#! $python^"
  '';

  meta = {
    homepage = https://github.com/spesmilo/obelisk;
    description = "Scalable Bitcoin backend using libbitcoin";
    license = stdenv.lib.licenses.agpl3;
    platforms = stdenv.lib.platforms.linux;
  };
}
