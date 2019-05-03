{ stdenv, fetchFromGitHub, autoreconfHook, libewf, afflib, openssl, zlib }:

stdenv.mkDerivation rec {
  version = "4.6.6";
  pname = "sleuthkit";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "${pname}-${version}";
    sha256 = "07lpka1sps95d0gfx1l09sp8m74h1v8ibjjd8877dbpq2pi6yay6";
  };

  postPatch = ''
    substituteInPlace tsk/img/ewf.cpp --replace libewf_handle_read_random libewf_handle_read_buffer_at_offset
  '';

  enableParallelBuilding = true;

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ libewf afflib openssl zlib ];

  # Hack to fix the RPATH.
  preFixup = "rm -rf */.libs";

  meta = {
    description = "A forensic/data recovery tool";
    homepage = https://www.sleuthkit.org/;
    maintainers = [ stdenv.lib.maintainers.raskin ];
    platforms = stdenv.lib.platforms.linux;
    license = stdenv.lib.licenses.ipl10;
    inherit version;
  };
}
