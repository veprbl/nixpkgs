{ stdenv, fetchurl, pkgconfig, freetype, expat }:

stdenv.mkDerivation rec {
  name = "fontconfig-2.11.1";

  src = fetchurl {
    url = "${meta.homepage}/release/${name}.tar.bz2";
    sha256 = "16baa4g5lswkyjlyf1h5lwc0zjap7c4d8grw79349a5w6dsl8qnw";
  };

  patches = [ ./cache-regen.patch ];

  propagatedBuildInputs = [ freetype ];
  buildInputs = [ pkgconfig expat ];

  configureFlags = [
    "--with-cache-dir=/var/cache/fontconfig"
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


  /** $out/etc/fonts/* is the root configuration file that
      sets the default upstream configuration and adds other configs (if available):
        - nix-specific & machine-specific /etc/fonts-nix/fonts.conf
        - user-specific $XDG_CONFIG_HOME/fontconfig/fonts.conf
  */
  postInstall = ''
    (
      cd "$out/etc/fonts"
      patch < ${./nix-paths.diff}
    )
  '';

  meta = with stdenv.lib; {
    description = "A library for font customization and configuration";
    homepage = http://fontconfig.org/;
    license = licenses.bsd2; # custom but very bsd-like
    platforms = platforms.all;
    maintainers = [ maintainers.vcunat ];
  };
}
