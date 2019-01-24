{ stdenv, fetchurl, pkgconfig, freetype, expat
}:
let
  FC_ARCHITECTURE = import ./fc-arch.nix { platform = stdenv.hostPlatform; };
in
stdenv.mkDerivation rec {
  name = "fontconfig-${version}";
  version = "2.10.2";

  src = fetchurl {
    url = "http://fontconfig.org/release/${name}.tar.bz2";
    sha256 = "0llraqw86jmw4vzv7inskp3xxm2gc64my08iwq5mzncgfdbfza4f";
  };

  outputs = [ "bin" "dev" "lib" "out" ]; # $out contains all the config

  propagatedBuildInputs = [ freetype ];
  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ expat ];

  configureFlags = [
    "--with-arch=${FC_ARCHITECTURE}"
    "--sysconfdir=/etc"
    "--with-cache-dir=/var/cache/fontconfig"
    "--disable-docs"
    "--with-default-fonts="
  ];

  enableParallelBuilding = true;

  doCheck = true;

  # Don't try to write to /var/cache/fontconfig at install time.
  installFlags = "sysconfdir=$(out)/etc fc_cachedir=$(TMPDIR)/dummy RUN_FC_CACHE_TEST=false";

  passthru = {
    # Empty for backward compatibility, there was no versioning before 2.11
    configVersion = "";
  };

  meta = with stdenv.lib; {
    description = "A library for font customization and configuration";
    homepage = http://fontconfig.org/;
    license = licenses.bsd2; # custom but very bsd-like
    platforms = platforms.all;
    maintainers = [ maintainers.vcunat ];
  };
}
