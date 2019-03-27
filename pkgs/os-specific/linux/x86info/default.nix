{stdenv, fetchurl, fetchFromGitHub, pkgconfig, pciutils, python}:

stdenv.mkDerivation rec {
  version = "1.31pre";
  pname = "x86info";

  src = fetchFromGitHub {
    owner = "kernelslacker";
    repo = pname;
    rev = "1b41e8b338da6a18092e62e61295028ad59a3c2b";
    sha256 = "0phnhrh8xjq1lxmnhb9b9lc8c8x4mz0a95xjrd7i6ks61lfvrrnd";
  };
  #src = fetchurl {
  #  url = "http://codemonkey.org.uk/projects/x86info/${name}.tgz";
  #  sha256 = "0a4lzka46nabpsrg3n7akwr46q38f96zfszd73xcback1s2hjc7y";
  #};

  preConfigure = ''
    patchShebangs .

    # don't treat warnings as errors
    substituteInPlace Makefile --replace -Werror ""
    substituteInPlace lsmsr/Makefile --replace -Werror ""
  '';

  nativeBuildInputs = [ python pkgconfig ];
  buildInputs = [ pciutils ];

  postBuild = ''
    make -C lsmsr
  '';

  installPhase = ''
    install -Dm755 -t $out/bin x86info lsmsr/lsmsr
    install -Dm655 -T lsmsr/lsmsr.8 $out/share/man/man8/lsmsr.8
    install -Dm655 -T x86info.1 $out/share/man/man1/x86info.1
  '';

  meta = {
    description = "Identification utility for the x86 series of processors";
    longDescription =
    ''
      x86info will identify all Intel/AMD/Centaur/Cyrix/VIA CPUs. It leverages
      the cpuid kernel module where possible.  it supports parsing model specific
      registers (MSRs) via the msr kernel module.  it will approximate processor
      frequency, and identify the cache sizes and layout. 
    '';
    platforms = [ "i686-linux" "x86_64-linux" ];
    license = stdenv.lib.licenses.gpl2;
    homepage = http://codemonkey.org.uk/projects/x86info/;
    maintainers = with stdenv.lib.maintainers; [jcumming];
  };
}
