{ stdenv
, lib
, julia
, pkgs
}:

self:
super:

{
  pinnedPackages = {
    Compat = { version = "0.53.0"; };
  };

  Cairo = super.Cairo.override {
    buildInputs = with pkgs;
    [ fontconfig glib libpng gettext freetype libffi pixman cairo pango ];
    patches = lib.optionals stdenv.isDarwin [ ./patches/darwin_Cairo.patch ];
  };

  MbedTLS = super.MbedTLS.override {
    buildInputs = [ pkgs.mbedtls ];
  };

  Rmath = super.Rmath.override {
    patches = lib.optionals stdenv.isDarwin [ ./patches/darwin_Rmath.patch ];
  };

  ZMQ = super.ZMQ.override {
    buildInputs = [ pkgs.zeromq3 ];
  };
}
