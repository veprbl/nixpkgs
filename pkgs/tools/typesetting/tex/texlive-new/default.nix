/* (new) TeX Live user docs
  - Basic usage: just pull texlive.combined.scheme-basic
  for an environment with basic LaTeX support.
  There are all the schemes as defined upstream (with tiny differences, perhaps).
  - You can compose your own collection like this:
    texlive.combine {
      inherit (texlive) scheme-small collection-langkorean algorithms cm-super;
    }
  - By default you only get executables and files needed during runtime,
  and a little documentation for the core packages.
  To change that, you need to add `pkgFilter` function to `combine`.
    texlive.combine {
      # inherit (texlive) whatever-you-want;
      pkgFilter = pkg:
        pkg.tlType == "run" || pkg.tlType == "bin" || pkg.pname == "cm-super";
     # elem tlType [ "run" "bin" "doc" "source" ]
     # there are also other attributes: version, name
    }
  - Known bugs:
    * some tools are missing, e.g.: epstopdf
    * luatex executables segfault since the time they were split from others
    * xetex is likely to have problems finding fonts
    * some apps aren't packaged/tested yet (xdvi, asymptote, biber, etc.)
    * feature/bug: when a package is rejected by pkgFilter,
      its dependencies are still propagated
    * scheme-full is disabled ATM, as it didn't evaluate
*/

{ stdenv, lib, fetchurl, runCommand, buildEnv
, callPackage, ghostscriptX, harfbuzz, poppler_nox
, makeWrapper, perl, python, ruby
}:
let
  # TODOs:
  #   - maybe fixup scripts in individual packages

  # various binaries (compiled)
  bin = callPackage ./bin.nix {
    poppler = poppler_nox; # otherwise depend on various X stuff
    ghostscript = ghostscriptX;
    harfbuzz = harfbuzz.override {
      withIcu = true; withGraphite2 = true;
    };
  };

  # function for creating a working environment from a set of TL packages
  combine = import ./combine.nix {
    inherit bin combinePkgs buildEnv fastUnique lib makeWrapper perl stdenv python ruby;
  };

  # the set of TeX Live packages, collections, and schemes; using upstream naming
  tl = let
    /* curl ftp://tug.ctan.org/pub/tex/historic/systems/texlive/2015/tlnet-final/tlpkg/texlive.tlpdb.xz \
        | xzcat | uniq -u | sed -rn -f ./tl2nix.sed > ./pkgs.nix */
    orig = removeAttrs (import ./pkgs.nix tl) [ "scheme-full" ];
    clean = orig // {
      # overrides of texlive.tlpdb

      tetex = orig.tetex // { # 2015.08.27 as we need version with mktexlsr.pl
        # TODO: official hashed mirror
        urlPrefix = "http://lipa.ms.mff.cuni.cz/~cunav5am/nix";
        md5.run = "4b4c0208124dfc9c8244c24421946d36";
        md5.doc = "983f5e5b5f4e407760b4ec176cf6a58f";
        version = "3.0"; # it's the same
        postUnpack = "cd $out && patch -p2 < ${./texlinks.patch} || true";
        # TODO: postUnpack per tlType instead of these hacks
      };

      dvidvi = orig.dvidvi // {
        hasRunfiles = false; # only contains docs that's in bin.core.doc already
      };
      texlive-msg-translations = orig.texlive-msg-translations // {
        hasRunfiles = false; # only *.po for tlmgr
      };

      # remove dependency-heavy packages from the basic collections
      collection-basic = orig.collection-basic // {
        deps = removeAttrs orig.collection-basic.deps [ "luatex" "metafont" "xdvi" ];
      };
      latex = orig.latex // {
        deps = removeAttrs orig.latex.deps [ "luatex" ];
      };
    }; # overrides

    # tl =
    in lib.mapAttrs flatDeps clean;
    # TODO: texlive.infra for web2c config?


  flatDeps = pname: attrs:
    let
      version = attrs.version or bin.version;
      mkPkgV = tlType: let
        pkg = attrs // {
          md5 = attrs.md5.${tlType};
          inherit pname tlType version;
        };
        in mkPkgs {
          inherit (pkg) pname tlType version;
          pkgList = [ pkg ];
        };
    in {
      # TL pkg contains lists of packages: runtime files, docs, sources, binaries
      pkgs =
        # tarball of a collection/scheme itself only contains a tlobj file
        [( if (attrs.hasRunfiles or false) then mkPkgV "run"
            # the fake derivations are used for filtering of hyphenation patterns
          else { inherit pname version; tlType = "run"; }
        )]
        ++ lib.optional (attrs.md5 ? "doc") (mkPkgV "doc")
        ++ lib.optional (attrs.md5 ? "source") (mkPkgV "source")
        ++ lib.optional (bin ? ${pname})
            ( bin.${pname} // { inherit pname; tlType = "bin"; } )
        ++ combinePkgs (attrs.deps or {});
    };

  # the basename used by upstream (without ".tar.xz" suffix)
  mkUrlName = { pname, tlType, ... }:
    pname + lib.optionalString (tlType != "run") ".${tlType}";

  unpackPkg =
    { # url ? null, urlPrefix ? null
      md5, pname, tlType, postUnpack ? "", stripPrefix ? 1, ...
    }@args: let
      url = args.url or "${urlPrefix}/${mkUrlName args}.tar.xz";
      urlPrefix = args.urlPrefix or
        ("${mirror}/pub/tex/historic/systems/texlive/${bin.year}/tlnet-final/archive");
      # beware: standard mirrors http://mirror.ctan.org/ don't have releases
      mirror = "ftp://tug.ctan.org"; # also works: ftp.math.utah.edu
    in  ''
          tar -xf '${ fetchurl { inherit url md5; } }' \
            '--strip-components=${toString stripPrefix}' \
            -C "$out" --anchored --exclude=tlpkg --keep-old-files
        '' + postUnpack;

  mkPkgs = { pname, tlType, version, pkgList }@args:
      /* TODOs:
          - make fixed-output *after* unpacking
            (to have same derivation even when stdenv/platform changes)
            for that we would need to download all and generate hashes on our own
          - "historic" isn't mirrored; posted a question at #287
          - maybe cache (some) collections? (they don't overlap)
      */
      runCommand "texlive-${mkUrlName args}-${version}"
        { # lots of derivations, not meant to be cached
          preferLocalBuild = true; allowSubstitutes = false;
          passthru = { inherit pname tlType version; };
        }
        ( ''
          mkdir "$out"
          '' + lib.concatMapStrings unpackPkg (fastUnique (a: b: a.md5 < b.md5) pkgList)
        );

  # combine a set of TL packages into a single TL meta-package
  combinePkgs = pkgSet: lib.concatLists # uniqueness is handled in `combine`
    (lib.mapAttrsToList (_n: a: a.pkgs) pkgSet);

  # TODO: replace by buitin once it exists
  fastUnique = comparator: list: with lib;
    let un_adj = l: if length l < 2 then l
      else optional (head l != elemAt l 1) (head l) ++ un_adj (tail l);
    in un_adj (lib.sort comparator list);

in
  tl // rec {
    inherit bin;

    combined = lib.mapAttrs
      (pname: attrs: combine { ${pname} = attrs; })
      { inherit (tl) /*scheme-full*/
          scheme-tetex scheme-medium scheme-small scheme-basic scheme-minimal
          scheme-context scheme-gust scheme-xml;
      };

    inherit combine;
  }

