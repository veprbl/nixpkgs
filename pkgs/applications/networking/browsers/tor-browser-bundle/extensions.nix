{ stdenv
, fetchgit
, fetchurl

# common
, zip

# HTTPS Everywhere
, git
, libxml2 # xmllint
, python36
, python36Packages
, rsync
}:

{
  https-everywhere = stdenv.mkDerivation rec {
    name = "https-everywhere-${version}";
    version = "2018.6.21";

    extid = "https-everywhere-eff@eff.org";

    src = fetchgit {
      url = "https://git.torproject.org/https-everywhere.git";
      rev = "refs/tags/${version}";
      sha256 = "0da22ha4q1jmi38shkwmp34xwx71hnchqq4yrmcms0r9rvvw3zar";
      fetchSubmodules = true; # for translations, TODO: remove
      leaveDotGit = true;
    };

    nativeBuildInputs = [
      git
      libxml2 # xmllint
      python36
      python36Packages.lxml
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
    version = "10.1.8.2";

    extid = "{73a6fe31-595d-460b-a920-fcc0f8843232}";

    src = fetchurl {
      url = "https://secure.informaction.com/download/releases/noscript-${version}.xpi";
      sha256 = "1q1r1pf3xx6cxmrlwr50zdg91aq5fp8df0rkcfhx2sbm6cv5s7yl";
    };

    unpackPhase = ":";

    installPhase = ''
      install -m 444 -D $src "$out/$extid.xpi"
    '';
  };

  torbutton = stdenv.mkDerivation rec {
    name = "torbutton-${version}";
    version = "2.0.1";

    extid = "torbutton@torproject.org";

    src = fetchgit {
      url = "https://git.torproject.org/torbutton.git";
      rev = "refs/tags/${version}";
      sha256 = "09gn4kkz02rh5vpk0nnr0r8m1im1qhlk85i15lrmqw72i7py9x8l";
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
    version = "0.2.16.1";

    extid = "tor-launcher@torproject.org";

    src = fetchgit {
      url = "https://git.torproject.org/tor-launcher.git";
      rev = "refs/tags/${version}";
      sha256 = "0rbkxnyki3j3x21cjg0s1k6hm016x41rcvhdsacpwsg5vgacbfrg";
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
