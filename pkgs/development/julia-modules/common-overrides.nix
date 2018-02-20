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
