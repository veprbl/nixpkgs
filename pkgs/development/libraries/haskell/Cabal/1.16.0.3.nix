# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, extensibleExceptions, filepath, HUnit, QuickCheck
, testFramework, testFrameworkHunit, testFrameworkQuickcheck2
}:

cabal.mkDerivation (self: {
  pname = "Cabal";
  version = "1.16.0.3";
  sha256 = "11lzqgdjaix8n7nabmafl3jf9gisb04c025cmdycfihfajfn49zg";
  buildDepends = [ filepath ];
  testDepends = [
    extensibleExceptions filepath HUnit QuickCheck testFramework
    testFrameworkHunit testFrameworkQuickcheck2
  ];
  doCheck = false;
  meta = {
    homepage = "http://www.haskell.org/cabal/";
    description = "A framework for packaging Haskell software";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    hydraPlatforms = self.stdenv.lib.platforms.none;
    maintainers = with self.stdenv.lib.maintainers; [ simons ];
  };
})
