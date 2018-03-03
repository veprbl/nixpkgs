{ stdenv, fetchFromGitHub, getopt, makeWrapper, autoreconfHook }:

stdenv.mkDerivation rec {
  name = "libseccomp-${version}";
  version = "2018-01-25";

  src = fetchFromGitHub {
    owner = "seccomp";
    repo = "libseccomp";
    rev = "a6cc6331923430ea08711bcdfd5684394fab1a6b";
    sha256 = "1pxmvshn5l3c2g5hqj56gnp54mv43j7nq2wwkrgvbdsn84viapca";
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ getopt makeWrapper ];

  patchPhase = ''
    patchShebangs .
  '';

  # Hack to ensure that patchelf --shrink-rpath get rids of a $TMPDIR reference.
  preFixup = "rm -rfv src";

  meta = with stdenv.lib; {
    description = "High level library for the Linux Kernel seccomp filter";
    homepage    = "https://github.com/seccomp/libseccomp";
    license     = licenses.lgpl21;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ thoughtpolice wkennington ];
  };
}
