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
          - how to patch shebangs?
            even ${coreutils}/bin/env would make a hash-dependency on stdenv
          - "historic" isn't mirrored; posted a question at #287
          - deal with empty packages (scan for runfiles?)
          - make fixed-output *after* unpacking
            (to have same derivation even when stdenv/platform changes)
            for that we would need to download all and generate hashes on our own
          - maybe cache (some) collections? (they don't overlap)
      */
        #url = "http://mirror.ctan.org/
        url = "ftp://tug.ctan.org/pub/tex/historic/systems/texlive/${bin.year}/tlnet-final/archive/${name}.tar.xz";
        # also works: ftp.math.utah.edu/pub/tex/historic

        # TODO: this is hacky fix
        md5 = if name != "tetex" then md5 else "2016b5ac0393732abb90546136b77b35"; # 2015.08.07
      };
    in runCommand "texlive-${name}-${version}"
        { # lots of derivations, not meant to be cached
          preferLocalBuild = true; allowSubstitutes = false;
          passthru = { inherit version; pName = name; };
        }
        (''
          mkdir "$out"
          tar -xf '${src}' -C "$out" --anchored --exclude=tlpkg \
            --keep-old-files
        '' + /* WTF? nesting depth differs among tarballs */ ''
          if [[ -d "$out/texmf-dist" ]]; then
            mv "$out"/{texmf-dist/*,}
            rmdir "$out/texmf-dist/"
          fi
        '');

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

    mine = combine { pkgSet = {
      inherit (tl-flatDeps)
        scheme-basic scheme-tetex
        units algorithms
        ;
    }; };

    combined = lib.mapAttrs
      (name: attrs: combine { pkgSet.${name} = attrs; })
      { inherit (tl-flatDeps)
          scheme-full scheme-medium scheme-small scheme-basic scheme-minimal
          scheme-context scheme-gust scheme-tetex scheme-xml;
      };

    combine = { pkgSet, pkgFilter ? (type: _n: type == "run") }:
      let metaPkg = combinePkgs pkgSet;
        # TODO: using multi-dir ls-R is likely usable to avoid symlinking most files
      in buildEnv {
        name = "texlive-combined-${bin.year}";

        extraPrefix = "/share/texmf";

        ignoreCollisions = false;
        paths = lib.unique #( "${bin}/share/texmf-dist" ]
          ( [ ]
          ++ lib.filter (pkgFilter "run") metaPkg.pkgs.run
          ++ lib.filter (pkgFilter "doc") metaPkg.pkgs.doc
          ++ lib.filter (pkgFilter "src") metaPkg.pkgs.src );
        #/*
        postBuild = ''
          cd "$out"
          mkdir -p ./bin
          ln -s '${bin}'/bin/{kpsewhich,kpseaccess,mktexfmt} ./bin/

          export PATH="$out/share/texmf/scripts/texlive:$out/bin:${perl}/bin:$PATH"
          export TEXMFDIST="$out/share/texmf"
          export TEXMFSYSCONFIG="$out/share/texmf-config"
          export TEXMFSYSVAR="$out/share/texmf-var"
          export PERL5LIB="$out/share/texmf/scripts/texlive"

          ln -s '${bin}/share/texmf-dist/scripts/texlive/TeXLive' "$out/share/texmf/scripts/texlive/"

          perl `type -P mktexlsr.pl`
          yes | perl `type -P updmap.pl` --sys --syncwithtrees || true
          yes | perl `type -P updmap.pl` --sys --syncwithtrees || true
          perl `type -P fmtutil.pl` --sys --all
          texlinks.sh
        '' +
        # TODO: also ${bin}/share/{man,info}
        ''
          ln -s texmf/doc/{man,info} "$out/share/"
        '';
        #*/
      };
      # TODO: some testing http://tug.org/texlive/doc/texlive-en/texlive-en.html#x1-380003.5
  }
  /*
  tl-srcs // {
  }
  #*/


