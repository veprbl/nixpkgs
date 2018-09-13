{ stdenv, lib, fetchgit, darwin
, buildRustCrate, defaultCrateOverrides }:

((import ./Cargo.nix {
  inherit lib buildRustCrate fetchgit;
  inherit (stdenv) buildPlatform;
}).cargo_download {}).override {
  crateOverrides = defaultCrateOverrides // {
    cargo-download = attrs: {
      buildInputs = lib.optional stdenv.isDarwin
        darwin.apple_sdk.frameworks.Security;
    };
  };
}
