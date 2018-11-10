{ stdenv, fetchurl }:

let version = "0.53";
in stdenv.mkDerivation {
  name = "unscd-${version}";

  src = fetchurl {
    url = "https://busybox.net/~vda/unscd/nscd-${version}.c";
    sha256 = "0h3s7ylnpid88hifmq6xb3qlbmx9vliwwcrk1jd4sd4w5ddjay4h";
  };

  unpackPhase = ":";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    $CC $src -o $out/bin/nscd
    runHook postInstall
  '';

  meta = with stdenv.lib; {
    homepage = https://busybox.net/~vda/unscd/;
    maintainers = with maintainers; [ matthewbauer ];
    description = "Drop in replacement for Glibc's nscd";
    longDescription = ''
      unscd is a single-threaded server process which offloads all NSS
      lookups to worker children (not threads, but fully independent
      processes). Cache hits are handled by parent. Only cache misses
      start worker children. This design is immune against resource
      leaks and hangs in NSS libraries.

      Currently (v0.36) it emulates glibc nscd pretty closely (handles
      same command line flags and config file), and is moderately
      tested.
    '';
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
