{ cabal, stm, transformers }:

cabal.mkDerivation (self: {
  pname = "monad-stm";
  version = "0.1.0.2";
  sha256 = "09bbhbj9zg928j3dnvvxsrv8hw1c7s0vj0wffrhs810aqlf1m9xp";
  buildDepends = [ stm transformers ];
  meta = {
    description = "MonadSTM class analogous to MonadIO";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
