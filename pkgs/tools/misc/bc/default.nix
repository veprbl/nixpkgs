{stdenv, autoreconfHook, buildPackages, fetchurl, flex, readline, ed, texinfo}:

stdenv.mkDerivation rec {
  name = "bc-1.07.1";
  src = fetchurl {
    url = "mirror://gnu/bc/${name}.tar.gz";
    sha256 = "62adfca89b0a1c0164c2cdca59ca210c1d44c3ffc46daf9931cf4942664cb02a";
  };

  configureFlags = [
    "--with-readline"
    "CC_FOR_BUILD=${buildPackages.stdenv.cc.targetPrefix}gcc"
  ];

  # As of 1.07 cross-compilation is quite complicated as the build system wants
  # to build a code generator, bc/fbc, on the build machine.
  patches = [ ./cross-bc.patch ];
  nativeBuildInputs = [autoreconfHook flex ed.out texinfo] ++
    stdenv.lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform)
    [buildPackages.stdenv.cc buildPackages.readline.out buildPackages.ncurses.out];
  buildInputs = [readline];

  makeFlags = ''HOST_READLINE=${buildPackages.readline.out.outPath}/lib HOST_NCURSES=${buildPackages.ncurses.out.outPath}/lib'';

  doCheck = stdenv.hostPlatform == stdenv.buildPlatform;

  meta = {
    description = "GNU software calculator";
    homepage = http://www.gnu.org/software/bc/;
    platforms = stdenv.lib.platforms.all;
  };
}
