{ cabal, syb }:

cabal.mkDerivation (self: {
  pname = "th-expand-syns";
  version = "0.3.0.4";
  sha256 = "05qgfam7zq02848icvddds67ch5d8py7r30izg4lp0df0kzn08yq";
  buildDepends = [ syb ];
  meta = {
    description = "Expands type synonyms in Template Haskell ASTs";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
