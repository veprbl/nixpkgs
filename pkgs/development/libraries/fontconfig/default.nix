{ stdenv, fetchurl, pkgconfig, freetype, expat }:

stdenv.mkDerivation rec {
  name = "fontconfig-2.11.1";

  src = fetchurl {
    url = "http://fontconfig.org/release/${name}.tar.bz2";
    sha256 = "16baa4g5lswkyjlyf1h5lwc0zjap7c4d8grw79349a5w6dsl8qnw";
  };
/*
  infinality_patch = with freetype.infinality; if useInfinality
    then let subvers = "1";
      in fetchurl {
        url = http://www.infinality.net/fedora/linux/zips/fontconfig-infinality-1-20130104_1.tar.bz2;
        sha256 = "1fm5xx0mx2243jrq5rxk4v0ajw2nawpj23399h710bx6hd1rviq7";
      }
    else null;
*/
  propagatedBuildInputs = [ freetype ];
  buildInputs = [ pkgconfig expat ];

  configureFlags = [
    "--with-cache-dir=/var/cache/fontconfig"
    "--disable-docs"
    "--with-default-fonts="
  ];

  # We should find a better way to access the arch reliably.
  crossArch = stdenv.cross.arch or null;

  preConfigure = ''
    if test -n "$crossConfig"; then
      configureFlags="$configureFlags --with-arch=$crossArch";
    fi
  '';

  enableParallelBuilding = true;

  doCheck = true;

  # Don't try to write to /var/cache/fontconfig at install time.
  installFlags = "fc_cachedir=$(TMPDIR)/dummy";
/*
  postInstall = stdenv.lib.optionalString freetype.infinality.useInfinality ''
    cd "$out/etc/fonts" && tar xvf ${infinality_patch}
  '';
*/
  meta = with stdenv.lib; {
    description = "A library for font customization and configuration";
    homepage = http://fontconfig.org/;
    license = licenses.bsd2; # custom but very bsd-like
    platforms = platforms.all;
    maintainers = [ maintainers.vcunat ];
  };
}
