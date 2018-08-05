{ config, lib, pkgs, ... }:

with lib;
let
  dmcfg = config.services.xserver.displayManager;
  ldmcfg = dmcfg.lightdm;
  cfg = ldmcfg.greeters.webGreeter;

  inherit (pkgs) linkFarm writeText lightdm-webkit2-greeter nixos-artwork;
  inherit (builtins) toString;

  xgreeters = linkFarm "lightdm-webkit2-greeter-xgreeters" [{
    path = webGreeterSession;
    name = "lightdm-webkit2-greeter.desktop";
  }];

  webGreeterSession = writeText "lightdm-webkit2-greeter.desktop" ''
    [Desktop Entry]
    Name=LightDM WebKit2 Greeter
    Comment=LightDM Greeter
    Exec=${lightdm-webkit2-greeter}/bin/lightdm-webkit2-greeter
    Type=Application
    X-Ubuntu-Gettext-Domain=lightdm-webkit2-greeter
  '';

  webGreeterConf = writeText "lightdm-webkit2-greeter.conf" ''
    [greeter]
    debug_mode          = ${toString cfg.debugMode}
    detect_theme_errors = ${toString cfg.detectThemeErrors}
    screensaver_timeout = ${toString cfg.screensaverTimeout}
    secure_mode         = ${toString cfg.secureMode}
    time_format         = ${cfg.timeFormat}
    time_language       = ${cfg.timeLanguage}
    webkit_theme        = ${cfg.webkitTheme}

    [branding]
    background_images = ${cfg.backgroundImages}
    logo              = ${cfg.logo}
    user_image        = ${cfg.userImage}

    ${cfg.extraConfig}
  '';
in {
  options = {
    services.xserver.displayManager.lightdm.greeters.webGreeter = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable lightdm-webkit2-greeter as the lightdm greeter.
        '';
      };

      debugMode = mkOption {
        type = types.bool;
        default = false;
        description = ''
           Greeter theme debug mode.
        '';
      };

      detectThemeErrors = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Provide an option to load a fallback theme when theme errors are detected.
        '';
      };

      screensaverTimeout = mkOption {
        type = types.int;
        default = 300;
        description = ''
          Blank the screen after this many seconds of inactivity.
        '';
      };

      secureMode = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Don't allow themes to make remote http requests.
        '';
      };

      timeFormat = mkOption {
        type = types.enum [ "LT" "LTS" "L" "LL" "LLL" "LLLL" "Z" "ZZ" "S" "SS" "SSS" "X" "k" "kk" ];
        default = "LT";
        description = ''
          A moment.js format string so the greeter can generate localized time for display.
        '';
      };

      timeLanguage = mkOption {
        type = types.str;
        default = "auto";
        description = ''
          Language to use when displaying the time or "auto" to use the system's language.
        '';
      };

      webkitTheme = mkOption {
        type = types.str;
        default = "antergos";
        description = ''
          Webkit theme to use.
        '';
      };

      backgroundImages = mkOption {
        type = types.path;
        default = "${nixos-artwork.wallpapers.gnome-dark}/share/artwork/gnome";
        description = ''
          Path to directory that contains background images for use by themes.
        '';
      };

      logo = mkOption {
        type = types.path;
        default = "${lightdm-webkit2-greeter}/share/lightdm-webkit/themes/antergos/img/antergos.png";
        description = ''
          Path to logo image for use by greeter themes.
        '';
      };

      userImage = mkOption {
        type = types.path;
        default = "${lightdm-webkit2-greeter}/share/lightdm-webkit/themes/antergos/img/antergos-logo-user.png";
        description = ''
          Default user image/avatar.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Extra configuration to put in lightdm-webkit2-greeter.conf.
        '';
      };
    };
  };

  config = mkIf (ldmcfg.enable && cfg.enable) {
    environment.etc."lightdm/lightdm-webkit2-greeter.conf".source = webGreeterConf;

    services.xserver.displayManager.lightdm = {
      greeters.gtk.enable = false;

      greeter = mkDefault {
        package = xgreeters;
        name = "lightdm-webkit2-greeter";
      };
    };
  };
}
