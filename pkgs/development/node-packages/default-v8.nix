{ pkgs, nodejs, stdenv }:

let
  nodePackages = import ./composition-v8.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };
in
nodePackages // {
  pnpm = nodePackages.pnpm.override {
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postInstall = let
      pnpmLibPath = stdenv.lib.makeBinPath [
        nodejs.passthru.python
        nodejs
      ];
    in ''
      for prog in $out/bin/*; do
        wrapProgram "$prog" --prefix PATH : ${pnpmLibPath}
      done
    '';
  };
  joplin = nodePackages.joplin.override {
    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = with pkgs; [
      # sharp
      # http://sharp.pixelplumbing.com/en/stable/install/
      cairo expat fontconfig freetype fribidi gettext giflib
      glib harfbuzz lcms libcroco libexif libffi libgsf
      libjpeg_turbo libpng librsvg libtiff vips
      libwebp libxml2 pango pixman zlib
    ];
    #NIX_CFLAGS_COMPILE = [ "-I${pkgs.glib.dev}/include/glib-2.0" "-I${pkgs.glib.out}/lib/glib-2.0/include" /* :( */ ];
    #dontNpmInstall = true;
  };
}
