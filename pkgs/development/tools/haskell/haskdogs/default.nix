{ cabal, Cabal, filepath, HSH }:

cabal.mkDerivation (self: {
  pname = "haskdogs";
  version = "0.3.2";
  sha256 = "0vl3c66ki9j9ncs2rapdn80kbfk0l3y97qwfraqlnjycdl10sm6r";
  isLibrary = false;
  isExecutable = true;
  buildDepends = [ Cabal filepath HSH ];
  meta = {
    homepage = "http://github.com/ierton/haskdogs";
    description = "Generate ctags file for haskell project directory and it's deps";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = [ self.stdenv.lib.maintainers.andres ];
  };
})
