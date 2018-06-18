{ stdenv, wakatime, vscode-utils }:

let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;
in
  buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "vscode-wakatime";
      publisher = "WakaTime";
      version = "1.2.2";
      sha256 = "1cf4a4a3e0c35f293124e5613c29cfec850f67c0c43cec2ce1d8cc2e83aa217f";
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
