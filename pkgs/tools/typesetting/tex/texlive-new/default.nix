{ stdenv, lib, fetchurl, runCommand, buildEnv
, callPackage, ghostscriptX, harfbuzz, poppler_nox
, perl, makeWrapper
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
    inherit bin combinePkgs buildEnv fastUnique lib makeWrapper perl stdenv;
  };

  # the set of TeX Live packages, collections, and schemes; using upstream naming
  tl = let
    /* curl ftp://tug.ctan.org/pub/tex/historic/systems/texlive/2015/tlnet-final/tlpkg/texlive.tlpdb.xz \
      | xzcat | sed -rn -f ./tl2nix.sed > ./pkgs.nix */
    orig = removeAttrs (import ./pkgs.nix tl) [ "trash" ];
    clean = orig // {
      # overrides of texlive.tlpdb

      tetex = orig.tetex // { # 2015.08.27 as we need version with mktexlsr.pl
        # TODO: URL to fetch from
        md5.run = "4b4c0208124dfc9c8244c24421946d36";
        md5.doc = "983f5e5b5f4e407760b4ec176cf6a58f";
        version = "3.0"; # it's the same
        postUnpack = "cd $out && patch -p2 < ${./texlinks.patch}";
        # TODO: postUnpack per tlType
      };
      dvidvi.md5 = { # only contains docs that's in bin.core.doc already
      };
      hyphen-base = orig.hyphen-base // {
        # hacky fixup for: I can't find file `dehypht-x-2014-05-21.tex'
        # now we have missing language.def instead
        postUnpack = ''rm "$out"/tex/generic/config/language*.{def,dat}'';
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
    };
    # tl =
    in lib.mapAttrs flatDeps clean;
    # TODO: texlive.infra for web2c config?

  flatDeps = pname: attrs:
    let
      mkPkgV = tlType: let
        pkg = { version = bin.year; } // attrs // {
          md5 = attrs.md5.${tlType};
          inherit tlType;
          pname = pname + lib.optionalString (tlType != "run") ".${tlType}";
        };
        in mkPkgs {
          inherit (pkg) pname tlType version;
          pkgList = [ pkg ];
        };
    in {
      # TL pkg contains lists of packages: runtime files, docs, sources, binaries
      pkgs =
        # tarball of a collection/scheme itself only contains a tlobj file
        lib.optional (attrs.hasRunfiles or false) (mkPkgV "run")
        ++ lib.optional (attrs.md5 ? "doc") (mkPkgV "doc")
        ++ lib.optional (attrs.md5 ? "source") (mkPkgV "source")
        ++ lib.optional (bin ? ${pname}) (bin.${pname} // { tlType = "bin"; })
        ++ combinePkgs (attrs.deps or {});
    };

  unpackPkg =
    { url ? "ftp://tug.ctan.org/pub/tex/historic/systems/texlive/${bin.year}/tlnet-final/archive/${pname}.tar.xz"
        # "http://mirror.ctan.org/
        # also works: ftp.math.utah.edu/pub/tex/historic
    , md5, pname, postUnpack ? "", stripPrefix ? 1, ...
    }:
        ''
          tar -xf '${ fetchurl { inherit url md5; } }' \
            '--strip-components=${toString stripPrefix}' \
            -C "$out" --anchored --exclude=tlpkg --keep-old-files
        '' + postUnpack;

  mkPkgs = { pname, tlType, version, pkgList }:
      /* TODOs:
          - make fixed-output *after* unpacking
            (to have same derivation even when stdenv/platform changes)
            for that we would need to download all and generate hashes on our own
          - "historic" isn't mirrored; posted a question at #287
          - maybe cache (some) collections? (they don't overlap)
      */
      runCommand "texlive-${pname}-${version}"
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
    # TODO: remove
    mine = combine {
      inherit (tl) scheme-small units algorithms cm-super;
    };

    combined = lib.mapAttrs
      (pname: attrs: combine { ${pname} = attrs; })
      { inherit (tl)
          scheme-full scheme-medium scheme-small scheme-basic scheme-minimal
          scheme-context scheme-gust scheme-tetex scheme-xml;
      };

    inherit combine;
  }

