{ stdenv, fetchurl
, libopcodes, libbfd, libelf
, linuxPackages_latest
}:

stdenv.mkDerivation rec {
  name = "bpftool-${version}";
  inherit (linuxPackages_latest.kernel) version src;

  buildInputs = [ libopcodes libbfd libelf ];
  makeFlags = [ "V=1" ];

  preConfigure = ''
    cd tools/bpf/bpftool
    substituteInPlace ./Makefile \
      --replace '/usr/local' "$out" \
      --replace '/usr'       "$out" \
      --replace '/sbin'      '/bin'
  '';

  meta = with stdenv.lib; {
    description = "Debugging/program analysis tool for the eBPF subsystem";
    license     = [ licenses.gpl2 licenses.bsd2 ];
    platforms   = platforms.all;
    maintainers = with maintainers; [ thoughtpolice ];
  };
}
