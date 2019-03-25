{ stdenv, fetchgit, cmake, elfutils, zlib }:

stdenv.mkDerivation rec {
  pname = "pahole";
  version = "2019-03-12";
  #version = "1.12";
  src = fetchgit {
    url = https://git.kernel.org/pub/scm/devel/pahole/pahole.git;
    sha256 = "03ywx2ls3jxdw8wgpf9imp7zx46y4mxy1d808bz5vrymmb8hp8g0";
    #rev = "v${version}";
    rev = "fa963e1a8698e1f1c842a707971939cbc8ce3ff2";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ elfutils zlib ];

  # Put libraries in "lib" subdirectory, not top level of $out
  cmakeFlags = [ "-D__LIB=lib" ];

  meta = with stdenv.lib; {
    homepage = https://git.kernel.org/cgit/devel/pahole/pahole.git/;
    description = "Pahole and other DWARF utils";
    license = licenses.gpl2;

    platforms = platforms.linux;
    maintainers = [ maintainers.bosu ];
  };
}
