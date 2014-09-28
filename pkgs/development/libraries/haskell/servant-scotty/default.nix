# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, aeson, httpTypes, scotty, servant, servantResponse, text
, transformers
}:

cabal.mkDerivation (self: {
  pname = "servant-scotty";
  version = "0.1.1";
  sha256 = "0d3yc7aa2p1izizqnj81iscj9hbgbkpyav1ncmxzkr48svr6h783";
  buildDepends = [
    aeson httpTypes scotty servant servantResponse text transformers
  ];
  meta = {
    homepage = "http://github.com/zalora/servant";
    description = "Generate a web service for servant 'Resource's using scotty and JSON";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
