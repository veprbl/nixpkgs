{ cabal, binary, binaryShared, Cabal, deepseq, enumerator, filepath
, gio, glib, gtk, gtksourceview2, hslogger, leksahServer, ltk, mtl
, network, parsec, QuickCheck, regexBase, regexTdfa, strict, text
, time, transformers, utf8String
}:

cabal.mkDerivation (self: {
  pname = "leksah";
  version = "0.12.1.2";
  sha256 = "01gang44cdm9xg1dx1273prkhcniidagm2r90qh4v5mrdq8139v0";
  isLibrary = true;
  isExecutable = true;
  buildDepends = [
    binary binaryShared Cabal deepseq enumerator filepath gio glib gtk
    gtksourceview2 hslogger leksahServer ltk mtl network parsec
    QuickCheck regexBase regexTdfa strict text time transformers
    utf8String
  ];
  noHaddock = true;
  meta = {
    homepage = "http://www.leksah.org";
    description = "Haskell IDE written in Haskell";
    license = "GPL";
    platforms = self.stdenv.lib.platforms.linux;
    maintainers = [ self.stdenv.lib.maintainers.andres ];
  };
})
