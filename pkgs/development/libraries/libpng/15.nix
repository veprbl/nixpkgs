{ stdenv, fetchurl, zlib }:

assert zlib != null;

stdenv.mkDerivation rec {
  name = "libpng-1.5.22";

  src = fetchurl {
    url = "mirror://sourceforge/libpng/${name}.tar.xz";
    sha256 = "0xmgs22jpkw9638vwa5anv7b2mzmqvcsxrnvqd6nadhjj7xz1gr9";
  };

  propagatedBuildInputs = [ zlib ];

  doCheck = true;

  passthru = { inherit zlib; };

  meta = {
    description = "The official reference implementation for the PNG file format";
    homepage = http://www.libpng.org/pub/png/libpng.html;
    license = stdenv.lib.licenses.libpng;
    maintainers = with stdenv.lib.maintainers; [ fuuzetsu ];
    branch = "1.5";
  };
}
