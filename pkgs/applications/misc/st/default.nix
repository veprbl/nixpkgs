{ stdenv, fetchurl, libX11, ncurses, libXext, libXft, fontconfig }:

stdenv.mkDerivation rec {
  name = "st-0.4.1";
  
  src = fetchurl {
    url = "http://dl.suckless.org/st/${name}.tar.gz";
    sha256 = "0cdzwbm5fxrwz8ryxkh90d3vwx54wjyywgj28ymsb5fdv3396bzf";
  };

  patchPhase = "patch -p0 < ${./solarized_powerline.patch}";
  
  buildInputs = [ libX11 ncurses libXext libXft fontconfig ];

  NIX_LDFLAGS = "-lfontconfig";

  installPhase = ''
    TERMINFO=$out/share/terminfo make install PREFIX=$out
  '';
    
  meta = {
    homepage = http://st.suckless.org/;
    license = "MIT";
    maintainers = with stdenv.lib.maintainers; [viric];
    platforms = with stdenv.lib.platforms; linux;
  };
}
