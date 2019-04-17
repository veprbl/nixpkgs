{ stdenv, fetchgit, cmake, elfutils, zlib }:

stdenv.mkDerivation rec {
  pname = "pahole";
  version = "1.13";
  src = fetchgit {
    url = https://git.kernel.org/pub/scm/devel/pahole/pahole.git;
    rev = "v${version}";
    sha256 = "19zg7c7w7z73x5j3k8v57c61fdx2kirf8kh2kk1dh5lskgl9jcq9";
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
