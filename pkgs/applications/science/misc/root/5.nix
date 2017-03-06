{ stdenv, fetchurl, root }:

stdenv.lib.overrideDerivation root (old: rec {
  name = "root-${version}";
  version = "5.34.36";

  src = fetchurl {
    url = "https://root.cern.ch/download/root_v${version}.source.tar.gz";
    sha256 = "1kbx1jxc0i5xfghpybk8927a0wamxyayij9c74zlqm0595gqx1pw";
  };

  preConfigure = ''
    substituteInPlace cint/cint/lib/posix/posix.h \
      --replace __DARWIN_UNIX03 1
  '';

  patches = [
    ./sw_vers_root5.patch

    ./thisroot.patch
  ];
})
