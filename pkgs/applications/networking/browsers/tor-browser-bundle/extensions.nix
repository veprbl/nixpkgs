{ stdenv
, fetchgit
, fetchurl

# common
, zip

# HTTPS Everywhere
, git
, libxml2 # xmllint
, python27
, python27Packages
, rsync
}:

{
  https-everywhere = stdenv.mkDerivation rec {
    name = "https-everywhere-${version}";
    version = "2019.1.31";

    extid = "https-everywhere-eff@eff.org";

    src = fetchgit {
      url = "https://git.torproject.org/https-everywhere.git";
      rev = "refs/tags/${version}";
      sha256 = "1dpnqhibw6w102qwyf2ns4cq3l0wnwlcj4vzdq53gpxiq7l8nhdy";
      fetchSubmodules = true; # for translations, TODO: remove
    };

    nativeBuildInputs = [
      git
      libxml2 # xmllint
      python27
      python27Packages.lxml
      rsync
      zip
    ];

    buildPhase = ''
      $shell ./make.sh ${version} --no-recurse
    '';

    installPhase = ''
      install -m 444 -D pkg/https-everywhere-$version-eff.xpi "$out/$extid.xpi"
    '';
  };

  noscript = stdenv.mkDerivation rec {
    name = "noscript-${version}";
    version = "10.6.1";

    extid = "{73a6fe31-595d-460b-a920-fcc0f8843232}";

    src = fetchurl {
      url = "https://secure.informaction.com/download/releases/noscript-${version}.xpi";
      sha256 = "09wprm8ca81b0b4g9j3crasmf0l0hvdlni0y5s5z44jx0k84fl5i";
    };

    unpackPhase = ":";

    installPhase = ''
      install -m 444 -D $src "$out/$extid.xpi"
    '';
  };

  torbutton = stdenv.mkDerivation rec {
    name = "torbutton-${version}";
    version = "2.1.6";

    extid = "torbutton@torproject.org";

    src = fetchgit {
      url = "https://git.torproject.org/torbutton.git";
      rev = "refs/tags/${version}";
      sha256 = "10x75hxjwi386lciizins3issr5mw0hqxyb954hzlf1i4s081j7x";
    };

    nativeBuildInputs = [ zip ];

    buildPhase = ''
      $shell ./makexpi.sh
    '';

    installPhase = ''
      install -m 444 -D pkg/torbutton-$version.xpi "$out/$extid.xpi"
    '';
  };

  tor-launcher = stdenv.mkDerivation rec {
    name = "tor-launcher-${version}";
    version = "0.2.18.2";

    extid = "tor-launcher@torproject.org";

    src = fetchgit {
      url = "https://git.torproject.org/tor-launcher.git";
      rev = "refs/tags/${version}";
      sha256 = "0bzfsfgp5g192h0rjkf3z27b6ybsvlhpal8dyi8fk4kmn81fgnr2";
    };

    nativeBuildInputs = [ zip ];

    buildPhase = ''
      make package
    '';

    installPhase = ''
      install -m 444 -D pkg/tor-launcher-$version.xpi "$out/$extid.xpi"
    '';
  };
}
