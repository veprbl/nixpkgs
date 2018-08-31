{ stdenv, fetchgit, pkgconfig
, libpng, libxcb, xcbutilimage }:

# xorg.libxcb

stdenv.mkDerivation rec {
  name = "justmonika-${version}";
  version = "2018-08-27";

  src = fetchgit {
    url = https://github.com/FirebornGD/justmonika;
    rev = "d8469964c67f5df8eeef07bceefaaad5a77016d4";
    sha256 = "010z0ckg0gp22qjspivy0y2chcsmalssz3amir91r3hl4nygmbbl";
  };

  buildInputs = [
    libpng
    libxcb
    xcbutilimage
  ];

  nativeBuildInputs = [
    pkgconfig
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp lock $out/bin
  '';

  meta = with stdenv.lib; {
    description = ''
      Just Monika screensaver for X11
    '';
    homepage = https://github.com/FirebornGD/justmonika;
    platforms = platforms.linux;
    license = licenses.gpl3;
  };
}
