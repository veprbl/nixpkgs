{ stdenv, wakatime, vscode-utils }:

let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "vscode-wakatime";
      publisher = "WakaTime";
      version = "1.2.3";
      sha256 = "770589adb359474e5079a41377843bd7ac9fae8b83fdd3cc0ce1c6fbf8ecebd8";
    };

    postPatch = ''
      mkdir -p out/wakatime-master

      cp -rt out/wakatime-master --no-preserve=all ${wakatime}/lib/python3.6/site-packages/wakatime
    '';

    meta = with stdenv.lib; {
      description = ''
        Visual Studio Code plugin for automatic time tracking and metrics generated
        from your programming activity
      '';
      license = licenses.bsd3;
      maintainers = with maintainers; [
        eadwu
      ];
    };
  }
