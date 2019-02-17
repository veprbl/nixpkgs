{ stdenv, lib, fetchFromGitHub, pkgconfig, asciidoc, docbook_xml_dtd_45
, docbook_xsl, libxslt, libxml2, makeWrapper, meson, ninja
/* neocomp deps */ , judy, freetype
, xorgproto, libxcb ,xcbutilrenderutil, xcbutilimage, pixman, libev
, dbus, libconfig, libdrm, libGL, pcre, libX11, libXcomposite, libXdamage
, libXinerama, libXrandr, libXrender, libXext, xwininfo, libxdg_basedir }:

let
  common = source: stdenv.mkDerivation (source // rec {
    name = "${source.pname}-${source.version}";

    nativeBuildInputs = (source.nativeBuildInputs or []) ++ [
      pkgconfig
      asciidoc
      docbook_xml_dtd_45
      docbook_xsl
      makeWrapper
    ];

    installFlags = [ "PREFIX=$(out)" ];

    postInstall = ''
      wrapProgram $out/bin/compton-trans \
        --prefix PATH : ${lib.makeBinPath [ xwininfo ]}
    '';

    meta = with lib; {
      description = "A fork of XCompMgr, a sample compositing manager for X servers";
      longDescription = ''
        A fork of XCompMgr, which is a sample compositing manager for X
        servers supporting the XFIXES, DAMAGE, RENDER, and COMPOSITE
        extensions. It enables basic eye-candy effects. This fork adds
        additional features, such as additional effects, and a fork at a
        well-defined and proper place.
      '';
      license = licenses.mit;
      maintainers = with maintainers; [ ertes enzime twey ];
      platforms = platforms.linux;
    };
  });

  stableSource = rec {
    pname = "compton";
    version = "0.1_beta2.5";

    COMPTON_VERSION = version;

    buildInputs = [
      dbus libX11 libXcomposite libXdamage libXrender libXrandr libXext
      libXinerama libdrm pcre libxml2 libxslt libconfig libGL
    ];

    src = fetchFromGitHub {
      owner = "chjj";
      repo = "compton";
      rev = "b7f43ee67a1d2d08239a2eb67b7f50fe51a592a8";
      sha256 = "1p7ayzvm3c63q42na5frznq3rlr1lby2pdgbvzm1zl07wagqss18";
    };

    meta = {
      homepage = https://github.com/chjj/compton/;
    };
  };

  gitSource = rec {
    pname = "compton-git";
#    version = "5.1";
    version = "2019-02-11";

    COMPTON_VERSION = "v${version}";

    nativeBuildInputs = [ meson ninja ];

    src = fetchFromGitHub {
      owner  = "yshui";
      repo   = "compton";
      #rev    = COMPTON_VERSION;
      rev    = "7a21cef9a4234e8323b72cffb241dd51e4cbba84";
      sha256 = "1xijpd3lvlwhppavdm1gkd3f6shah2690m47ch838wildxck4yy9";
    };

    buildInputs = [
      dbus libX11 libXext
      xorgproto
      libXinerama libdrm pcre libxml2 libxslt libconfig libGL
      # Removed:
      # libXcomposite libXdamage libXrender libXrandr

      # New:
      libxcb xcbutilrenderutil xcbutilimage
      pixman libev
      libxdg_basedir
    ];

    #postPatch = ''
    #  substituteInPlace meson.build --replace "version: '4'" "version: '${version}'"
    #'';

    NIX_CFLAGS_COMPILE = [ "-fno-strict-aliasing" ];

    mesonFlags = [
      "-Dvsync_drm=true"
      "-Dnew_backends=true"
      "-Dbuild_docs=true"
    ];

    meta = {
      homepage = https://github.com/yshui/compton/;
    };
  };

  neocomp = stdenv.mkDerivation rec {
    pname = "neocomp";
    version = "2019-01-06";

    COMPTON_VERSION = version;

    src = fetchFromGitHub {
      owner = "delusionallogic";
      repo = pname;
      rev = "740ba749f9a8227b2c9420b4ae3c948a505376f2";
      sha256 = "0w4yvhz3p9z0h59j7v415d85j3ybd5j7szsjp7xzzdqp2lq9gxkz";
    };

    nativeBuildInputs = [
      pkgconfig
      asciidoc
      docbook_xml_dtd_45
      docbook_xsl
      makeWrapper
    ];
    buildInputs = stableSource.buildInputs ++ gitSource.buildInputs # lol
    ++ [ freetype judy ];

    makeFlags = [
      "DESTDIR=${placeholder "out"}"
      "PREFIX="
    ];
    meta = with stdenv.lib; {
      description = "neocomp";
      # TODO
    };
  };
in {
  compton-old = common stableSource;
  compton-git = common gitSource;
  inherit neocomp;
}
