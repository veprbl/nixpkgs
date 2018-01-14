{stdenv, autoreconfHook, buildPackages, fetchurl, flex, readline, ed, texinfo}:

stdenv.mkDerivation rec {
  name = "bc-1.07.1";
  src = fetchurl {
    url = "mirror://gnu/bc/${name}.tar.gz";
    sha256 = "62adfca89b0a1c0164c2cdca59ca210c1d44c3ffc46daf9931cf4942664cb02a";
  };

  configureFlags = [ "--with-readline" ];

  # As of 1.07 cross-compilation is quite complicated as the build system wants
  # to build a code generator, bc/fbc, on the build machine.
  patches = [ ./cross-bc.patch ];
  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [autoreconfHook flex ed.out texinfo]
    ++ # needed for cross, see makeFlags below
    [buildPackages.readline.out buildPackages.ncurses.out];
  buildInputs = [readline];

  makeFlags = ''HOST_READLINE=${buildPackages.readline.out.outPath}/lib HOST_NCURSES=${buildPackages.ncurses.out.outPath}/lib'';

  doCheck = true;

  meta = {
    description = "GNU software calculator";
    homepage = http://www.gnu.org/software/bc/;
    platforms = stdenv.lib.platforms.all;
  };
}
