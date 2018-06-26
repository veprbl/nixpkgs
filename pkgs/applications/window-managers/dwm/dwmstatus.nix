{ stdenv, fetchgit
, libX11
, patches ? [] }:

let
  pkgname = "dwmstatus";
  rev = "e0bea395b27a50936a4db59ecb34775067eab4f3";
in
  stdenv.mkDerivation rec {
    name = "${pkgname}-${rev}";

    src = fetchgit {
      inherit rev;
      url = meta.homepage;
      sha256 = "031kc8pv13jy1hpfbrmahxn0xnkjfgpgmwdnc2vh6n8cbww4nncv";
    };

    inherit patches;

    postPatch = ''
      sed -i "s@PREFIX = /usr@PREFIX = $out@g" config.mk
    '';

    buildInputs = [
      libX11
    ];

    meta = with stdenv.lib; {
      homepage = "http://git.r-36.net/${pkgname}/";
      description = "Barebone status monitor with basic functions written in C";
      license = licenses.free;
      maintainers = with maintainers; [
        eadwu
      ];
      platforms = platforms.linux;
    };
  }
