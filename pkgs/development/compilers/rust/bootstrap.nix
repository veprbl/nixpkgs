{ stdenv, fetchurl, makeWrapper, cacert, zlib }:

let
  inherit (stdenv.lib) optionalString;

  platform =
    if stdenv.system == "i686-linux"
    then "i686-unknown-linux-gnu"
    else if stdenv.system == "x86_64-linux"
    then "x86_64-unknown-linux-gnu"
    else if stdenv.system == "i686-darwin"
    then "i686-apple-darwin"
    else if stdenv.system == "x86_64-darwin"
    then "x86_64-apple-darwin"
    else throw "missing bootstrap url for platform ${stdenv.system}";

  # fetch hashes by running `print-hashes.sh 2017-03-11 1.16.0`
  bootstrapHash =
    if stdenv.system == "i686-linux"
    then "b5859161ebb182d3b75fa14a5741e5de87b088146fb0ef4a30f3b2439c6179c5"
    else if stdenv.system == "x86_64-linux"
    then "48621912c242753ba37cad5145df375eeba41c81079df46f93ffb4896542e8fd"
    else if stdenv.system == "i686-darwin"
    then "26356b14164354725bd0351e8084f9b164abab134fb05cddb7758af35aad2065"
    else if stdenv.system == "x86_64-darwin"
    then "2d08259ee038d3a2c77a93f1a31fc59e7a1d6d1bbfcba3dba3c8213b2e5d1926"
    else throw "missing bootstrap hash for platform ${stdenv.system}";

  needsPatchelf = stdenv.isLinux;

  src = fetchurl {
     url = "https://static.rust-lang.org/dist/${date}/rust-${version}-${platform}.tar.gz";
     sha256 = bootstrapHash;
  };

  date = "2017-03-11";
  version = "1.16.0";
in

rec {
  rustc = stdenv.mkDerivation rec {
    name = "rustc-bootstrap-${version}";

    inherit version;
    inherit src;

    buildInputs = [ makeWrapper ];
    phases = ["unpackPhase" "installPhase"];

    installPhase = ''
      # Install both rustc and cargo in the bootstrap--we'll need that for the
      # build system to work properly.
      ./install.sh --prefix=$out \
        --components=rustc,rust-std-${platform},rust-docs,cargo

      ${optionalString needsPatchelf ''
        patchelf \
          --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
          "$out/bin/rustc"
        patchelf \
          --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
          "$out/bin/rustdoc"
        patchelf \
          --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
          "$out/bin/cargo"
      ''}

      # Do NOT, I repeat, DO NOT use `wrapProgram` on $out/bin/rustc
      # (or similar) here. It causes strange effects where rustc loads
      # the wrong libraries in a bootstrap-build causing failures that
      # are very hard to track dow. For details, see
      # https://github.com/rust-lang/rust/issues/34722#issuecomment-232164943
    '';
  };

  cargo = stdenv.mkDerivation rec {
    name = "cargo-bootstrap-${version}";

    inherit version;
    inherit src;

    buildInputs = [ makeWrapper zlib rustc ];
    phases = ["unpackPhase" "installPhase"];

    installPhase = ''
      ./install.sh --prefix=$out \
        --components=cargo

      ${optionalString needsPatchelf ''
        patchelf \
          --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
          "$out/bin/cargo"
      ''}

      wrapProgram "$out/bin/cargo" \
        --suffix PATH : "${rustc}/bin"
    '';
  };
}
