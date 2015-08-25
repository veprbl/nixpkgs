{ stdenv, lib, fetchurl, runCommand, buildEnv
, callPackage, ghostscriptX, harfbuzz
, perl
}:
let
  # TODO: fixup scripts in individual packages
  # but first try through setting env vars in bin/ aggregate,
  # as that would be needed anyway

  /* curl ftp://tug.ctan.org/pub/tex/historic/systems/texlive/2015/tlnet-final/tlpkg/texlive.tlpdb.xz \
    | xzcat | sed -rn -f ./tl2nix.sed > ./pkgs.nix */
  tl-clean = removeAttrs (import ./pkgs.nix tl-flatDeps) [ "trash" ];
  tl-flatDeps = lib.mapAttrs flatDeps tl-clean;

  flatDeps = name: attrs:
    if isSinglePackage name attrs
      then let mkPkgV = mkPkg (attrs.version or bin.year);
        in {
          # TL pkg contains three lists of packages: runtime files, docs, and sources
          pkgs.run = [ (mkPkgV name attrs.md5.run) ];
          pkgs.doc = lib.optional (attrs.md5 ? "doc")
            (mkPkgV "${name}.doc" attrs.md5.doc);
          pkgs.src = lib.optional (attrs.md5 ? "src")
            (mkPkgV "${name}.source" attrs.md5.src);
        }
      else
        combinePkgs attrs.deps;

  mkPkg = version: name: md5:
    let src = fetchurl {
      /* TODOs:
          - some src URLs have "source" instead of "src". Ask upstream?
          - "historic" isn't mirrored
          - deal with empty packages (scan for runfiles?)
          - make fixed-output *after* unpacking
            (to have same derivation even when stdenv/platform changes)
            for that we would need to download all and generate hashes on our own
      */
        #url = "http://mirror.ctan.org/
        url = "ftp://tug.ctan.org/pub/tex/historic/systems/texlive/${bin.year}/tlnet-final/archive/${name}.tar.xz";
        # also works: ftp.math.utah.edu/pub/tex/historic
        inherit md5;
      };
    in runCommand "texlive-${name}-${version}"
        { # lots of derivations, not meant to be cached
          preferLocalBuild = true; allowSubstitutes = false;
          passthru = { inherit version; pName = name; };
        }
        ''
          mkdir "$out"
          tar -xf '${src}' -C "$out" --anchored --exclude=tlpkg \
            --strip-components=1 --keep-old-files
        '';

  isSinglePackage = name: _attrs:
    (!lib.hasPrefix "collection-" name) && (!lib.hasPrefix "scheme-" name);

  # combine a set of TL packages into a single TL meta-package
  combinePkgs = pkgSet:
    let getFlat = attrName: lib.concatLists # uniqueness is handled in `combine`
        (map (dep: lib.getAttr attrName dep.pkgs)
          (lib.mapAttrsToList (_n: a: a) pkgSet));
    in { # tarball of a collection/scheme itself only contains a tlobj file
      pkgs.run = getFlat "run";
      pkgs.doc = getFlat "doc";
      pkgs.src = getFlat "src";
    };

  /*
  unpackPkgs = lib.concatMapStrings (src: ''
    echo "Unpacking '${src}'"
  '');
  */

  bin = callPackage ./bin.nix {
    ghostscript = ghostscriptX;
    harfbuzz = harfbuzz.override {
      withIcu = true; withGraphite2 = true;
    };
  };
in
   tl-flatDeps // rec {
    inherit bin;

    combined = lib.mapAttrs
      (name: attrs: combine { pkgSet.${name} = attrs; })
      { inherit (tl-flatDeps)
          scheme-full scheme-medium scheme-small scheme-basic scheme-minimal
          scheme-context scheme-gust scheme-tetex scheme-xml;
      };

    combine = { pkgSet, pkgFilter ? (type: _n: type == "run") }:
      let metaPkg = combinePkgs pkgSet;
      in buildEnv {
        name = "texlive-combined-${bin.year}";

        extraPrefix = "/share/texmf";

        ignoreCollisions = true; # let ${bin} versions shadow pkgSet versions
        paths = lib.unique ( [ "${bin}/share/texmf-dist" ]
          ++ lib.filter (pkgFilter "run") metaPkg.pkgs.run
          ++ lib.filter (pkgFilter "doc") metaPkg.pkgs.doc
          ++ lib.filter (pkgFilter "src") metaPkg.pkgs.src );
        /*
        preBuild = ''
          mkdir -p "$out/share/texmf"
          ln -s '${bin}/share/texmf-dist/'* "$out/share/texmf/"
        '';
        */

        postBuild = ''
          cd "$out"
          mkdir -p ./bin
          ln -s '${bin}'/bin/* ./bin/

          export PATH="$out/share/texmf/scripts/texlive:$out/bin:${perl}/bin:$PATH"
          export TEXMFSYSCONFIG="$out/share/texmf-config"

          mktexlsr ./share/texmf
          fmtutil-sys.sh --all
          yes | updmap.pl --sys --syncwithtrees || true
          texlinks.sh
        '';
      };
  }
  /*
  tl-srcs // {
  }
  #*/


