{ appimageTools, fetchurl, lib }:

let
  pname = "MineTime";
  version = "1.5.0";
in
appimageTools.wrapType2 rec {
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/marcoancona/MineTime/releases/download/v${version}/${name}-x86_64.AppImage";
    sha256 = "0zw3hiql3qs3srjj3pa8nx1b8b33lw4ah4j6faps3xzbp6rdwk0d";
  };

  extraPkgs = p: p.atomEnv.packages;

  # TODO: Don't replace if already set?
  profile = ''
    export LC_ALL=C.UTF-8
  '';

  meta = with lib; {
    description = "Modern, intuitive and smart calendar application";
    homepage = https://minetime.ai;
    # May become open-source in the future
    license = licenses.unfree;
    # Should be cross-platform, but for now we just grab the appimage
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ dtzWill ];
  };
}
