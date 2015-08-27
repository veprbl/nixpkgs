{ stdenv, lib, fetchurl, runCommand, buildEnv
, callPackage, ghostscriptX, harfbuzz
, perl, makeWrapper
}:
let
  # TODOs:
  #   - maybe fixup scripts in individual packages

  /* curl ftp://tug.ctan.org/pub/tex/historic/systems/texlive/2015/tlnet-final/tlpkg/texlive.tlpdb.xz \
    | xzcat | sed -rn -f ./tl2nix.sed > ./pkgs.nix */
  tl-clean =
    let orig = removeAttrs (import ./pkgs.nix tl-flatDeps) [ "trash" ];
    in orig // {
      # overrides of texlive.tlpdb

      tetex = { # 2015.08.07 as we need version with mktexlsr.pl
        md5.run = "2016b5ac0393732abb90546136b77b35";
        md5.doc = "b25e79ae27b6f3bd1622043cc79aca23";
        version = "3.0";
      };
      dvidvi.md5 = { # only contains docs that's in bin.doc already
      };
      hyphen-base = orig.hyphen-base // {
        # hacky fixup for: I can't find file `dehypht-x-2014-05-21.tex'
        postUnpack = ''rm "$out"/tex/generic/config/language*.{def,dat}'';
      };
    };

  tl-flatDeps = lib.mapAttrs flatDeps tl-clean;

  flatDeps = name: attrs:
        let
            mkPkgV = name: md5: mkPkg (attrs // { inherit name md5; });

            mkPkgVx = type: {
              ${type} = lib.optional (isSingle && attrs.md5 ? type)
                (mkPkg (attrs.version or bin.year) "${name}.${type}" attrs.md5.${type});
            };
            isSingle = isSinglePackage name attrs;
            combDeps = (combinePkgs (attrs.deps or {})).pkgs;
        in {
          # TL pkg contains three lists of packages: runtime files, docs, and sources
          pkgs = if false then # TODO: fix and finish the refactoring
            combDeps //
            mkPkgVx "run" //
            mkPkgVx "doc" //
            mkPkgVx "source"
          else  {
            # tarball of a collection/scheme itself only contains a tlobj file
            run = lib.optional (isSingle && attrs.md5 ? "run")
                (mkPkgV name attrs.md5.run)
              ++ (combDeps.run or []);
            doc = lib.optional (isSingle && attrs.md5 ? "doc")
                (mkPkgV "${name}.doc" attrs.md5.doc)
              ++ (combDeps.doc or []);
            source = lib.optional (isSingle && attrs.md5 ? "source")
                (mkPkgV "${name}.source" attrs.md5.source)
              ++ (combDeps.source or []);
          };
        };

  mkPkg =
    { name, version ? bin.year
    , url ? "ftp://tug.ctan.org/pub/tex/historic/systems/texlive/${bin.year}/tlnet-final/archive/${name}.tar.xz"
        # "http://mirror.ctan.org/
        # also works: ftp.math.utah.edu/pub/tex/historic
    , md5, postUnpack ? "", ...
    }:
      /* TODOs:
          - how to patch shebangs?
            even ${coreutils}/bin/env would make a hash-dependency on stdenv;
            posted a question
            -> make fixed-output *after* unpacking
              (to have same derivation even when stdenv/platform changes)
              for that we would need to download all and generate hashes on our own
          - "historic" isn't mirrored; posted a question at #287
          - deal with empty packages (scan for runfiles?)
          - maybe cache (some) collections? (they don't overlap)
      */
      runCommand "texlive-${name}-${version}"
        { # lots of derivations, not meant to be cached
          preferLocalBuild = true; allowSubstitutes = false;
          passthru = { inherit version; pName = name; };
        }
        (''
          mkdir "$out"
          tar -xf '${ fetchurl { inherit url md5; } }' \
            -C "$out" --anchored --exclude=tlpkg --keep-old-files
        '' + /* nesting depth differs among tarballs :-/ */ ''
          if [[ -d "$out/texmf-dist" ]]; then
            mv "$out"/{texmf-dist/*,}
            rmdir "$out/texmf-dist/"
          fi
        '' + postUnpack
        );

  isSinglePackage = name: _attrs:
    (!lib.hasPrefix "collection-" name) && (!lib.hasPrefix "scheme-" name);

  # combine a set of TL packages into a single TL meta-package
  combinePkgs = pkgSet:
    let
      #getAttrOr = default: attr: set:
      #  if lib.hasAttr attr set then lib.getAttr attr set else default;
      makeFlat = attrName: lib.concatLists # uniqueness is handled in `combine`
        (map (dep: lib.getAttr attrName dep.pkgs)
          (lib.mapAttrsToList (_n: a: a) pkgSet));
    in {
      pkgs.run = makeFlat "run";
      pkgs.doc = makeFlat "doc";
      pkgs.source = makeFlat "source";
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

  # TODO: replace by buitin once it exists
  fastUnique = list: with lib;
    let un_adj = l: if length l < 2 then l
      else optional (head l != elemAt l 1) (head l) ++ un_adj (tail l);
    in un_adj (lib.sort (a: b: a < b) list);
in
   tl-flatDeps // rec {
    inherit bin;

    # TODO: remove
    mine = combine { pkgSet = {
      inherit (tl-flatDeps)
        scheme-basic scheme-tetex
        units algorithms
        ;
    }; };

    combined = lib.mapAttrs
      (name: attrs: combine { ${name} = attrs; })
      { inherit (tl-flatDeps)
          scheme-full scheme-medium scheme-small scheme-basic scheme-minimal
          scheme-context scheme-gust scheme-tetex scheme-xml;
      };

    combine = args@{ pkgFilter ? (type: path: type == "run" || path == bin.doc), ... }:
      let
        pkgSet = removeAttrs args ["pkgFilter"] // {
          # include a fake "bin" package with docs for binaries
          bin.pkgs = { run = []; doc = [ bin.doc ]; source = []; };
        };
        metaPkg = combinePkgs pkgSet;
      in buildEnv {
        name = "texlive-combined-${bin.year}";

        extraPrefix = "/share/texmf";

        ignoreCollisions = false;
        paths = fastUnique (map builtins.toPath (
          [ ]
          ++ lib.filter (pkgFilter "run"   ) metaPkg.pkgs.run
          ++ lib.filter (pkgFilter "doc"   ) metaPkg.pkgs.doc
          ++ lib.filter (pkgFilter "source") metaPkg.pkgs.source
        ));

        buildInputs = [ makeWrapper ];

        postBuild = ''
          cd "$out"
          mkdir -p ./bin
          ln -s '${bin}'/bin/{kpsewhich,kpseaccess,mktexfmt} ./bin/

          export PATH="$out/bin:$out/share/texmf/scripts/texlive:${perl}/bin:$PATH"
          export TEXMFDIST="$out/share/texmf"
          export TEXMFSYSCONFIG="$out/share/texmf-config"
          export TEXMFSYSVAR="$out/share/texmf-var"
          export PERL5LIB="$out/share/texmf/scripts/texlive"

          mkdir -p "$out/share/texmf/scripts/texlive/"
          ln -s '${bin}/share/texmf-dist/scripts/texlive/TeXLive' "$out/share/texmf/scripts/texlive/"

          perl `type -P mktexlsr.pl`
          yes | perl `type -P updmap.pl` --sys --syncwithtrees || true
          yes | perl `type -P updmap.pl` --sys --syncwithtrees || true
          texlinks.sh "$out/bin"

          echo -e "\\n\\nBeware: fmtutil will try building even those formats for which files aren't installed\\n"
          perl `type -P fmtutil.pl` --sys --refresh
        '' +
        # TODO: a context trigger https://www.preining.info/blog/2015/06/debian-tex-live-2015-the-new-layout/
          # http://wiki.contextgarden.net/ConTeXt_Standalone#Unix-like_platforms_.28Linux.2FMacOS_X.2FFreeBSD.2FSolaris.29
        ''
          ln -s texmf/doc/{man,info} "$out/share/"
        '' +
        # wrap created executables with required env vars
        ''
          for link in ./bin/*; do
            [ -L "$link" -a -x "$link" ] || (echo -n Error:; ls -l "$link"; false)
            target=$(readlink "$link")
            case "$target" in
              /*)
                rm "$link";
                makeWrapper "$target" "$link" \
                  --prefix PATH : "$out/bin:$out/share/texmf/scripts/texlive:${perl}/bin" \
                  --prefix TEXMFDIST : "$out/share/texmf" \
                  --prefix TEXMFSYSCONFIG : "$out/share/texmf-config" \
                  --prefix TEXMFSYSVAR : "$out/share/texmf-var" \
                  --prefix PERL5LIB : "$out/share/texmf/scripts/texlive"
                ;;
              *) echo ,"$link", is OK;;
            esac
          done
        ''
        ;
      };
      # TODO: more testing http://tug.org/texlive/doc/texlive-en/texlive-en.html#x1-380003.5
      # TODO: make TeX fonts visible by fontconfig: it should be enough to install an appropriate file
  }

