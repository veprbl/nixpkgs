{stdenv, fetchurl, ncurses}:

stdenv.mkDerivation {
  name = "screen-4.0.3";
  src = fetchurl {
    url = mirror://gnu/screen/screen-4.0.3.tar.gz;
    sha256 = "0xvckv1ia5pjxk7fs4za6gz2njwmfd54sc464n8ab13096qxbw3q";
  };

  buildInputs = [ncurses];

  meta = {
    homepage = "http://www.gnu.org/software/screen/";
    description = "Full-screen window manager that multiplexes a physical terminal";

    platforms = stdenv.lib.platforms.unix;
    maintainers = [];
  };
}
