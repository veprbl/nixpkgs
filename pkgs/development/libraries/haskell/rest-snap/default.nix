# This file was auto-generated by cabal2nix. Please do NOT edit manually!

{ cabal, caseInsensitive, restCore, safe, snapCore
, unorderedContainers, uriEncode, utf8String
}:

cabal.mkDerivation (self: {
  pname = "rest-snap";
  version = "0.1.17.14";
  sha256 = "0fd6d85gzp9mr7y7bgfk9wscrhrych9q7cssps8m5l03n83d8asp";
  buildDepends = [
    caseInsensitive restCore safe snapCore unorderedContainers
    uriEncode utf8String
  ];
  meta = {
    description = "Rest driver for Snap";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
