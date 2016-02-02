{ config, lib, pkgs, ... }:

with lib;

{

  options = {

    fonts = {

      # TODO: find another name for it.
      fonts = mkOption {
        type = types.listOf types.path;
        default = [];
        example = literalExample "[ pkgs.dejavu_fonts ]";
        description = "List of primary font paths.";
      };

      enableDefaultFonts = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable a basic set of fonts providing several font styles
          and families and reasonable coverage of Unicode.
        '';
      };

    };

  };

  config = {

    fonts.fonts = mkIf config.fonts.enableDefaultFonts
      [
        pkgs.dejavu_fonts   # our default font; see ./fontconfig.nix
        pkgs.liberation_ttf # metric-compatibles for classic corefonts
      ];

  };

}
