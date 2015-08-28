{ stdenv, lib, fetchurl, runCommand, buildEnv
, callPackage, ghostscriptX, harfbuzz, poppler_nox
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

      tetex = orig.tetex // { # 2015.08.07 as we need version with mktexlsr.pl
        md5.run = "2016b5ac0393732abb90546136b77b35";
        md5.doc = "b25e79ae27b6f3bd1622043cc79aca23";
        version = "3.0"; # it's the same
      };
      dvidvi.md5 = { # only contains docs that's in bin.doc already
      };
      hyphen-base = orig.hyphen-base // {
        # hacky fixup for: I can't find file `dehypht-x-2014-05-21.tex'
        # now we have missing language.def instead
        postUnpack = ''rm "$out"/tex/generic/config/language*.{def,dat}'';
      };
      texlive-msg-translations = orig.texlive-msg-translations // {
        hasRunfiles = false; # only *.po for tlmgr
      };
    };

  tl-flatDeps = lib.mapAttrs flatDeps tl-clean;

  flatDeps = pname: attrs:
        let
            mkPkgV = pname: md5: let pkg = attrs // { inherit pname md5; };
              in mkPkgs {
                inherit pname; pkgList = [ pkg ];
                version = attrs.version or bin.year;
              };

            mkPkgVx = type: {
              ${type} = lib.optional (attrs.md5 ? type)
                (mkPkgs (attrs.version or bin.year) "${pname}.${type}" attrs.md5.${type});
            };
            combDeps = (combinePkgs (attrs.deps or {})).pkgs;
        in {
          # TL pkg contains three lists of packages: runtime files, docs, and sources
          pkgs = if false then # TODO: fix and finish the refactoring
            combDeps //
            mkPkgVx "run" //
            mkPkgVx "doc" //
            mkPkgVx "source"
          else {
            # tarball of a collection/scheme itself only contains a tlobj file
            run = lib.optional (attrs.hasRunfiles or false)
                (mkPkgV pname attrs.md5.run)
              ++ (combDeps.run or []);
            doc = lib.optional (attrs.md5 ? "doc")
                (mkPkgV "${pname}.doc" attrs.md5.doc)
              ++ (combDeps.doc or []);
            source = lib.optional (attrs.md5 ? "source")
                (mkPkgV "${pname}.source" attrs.md5.source)
              ++ (combDeps.source or []);
          };
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

  mkPkgs = { pname, version, pkgList }:
      /* TODOs:
          - how to patch shebangs?
            even ${coreutils}/bin/env would make a hash-dependency on stdenv;
            posted a question
            -> make fixed-output *after* unpacking
              (to have same derivation even when stdenv/platform changes)
              for that we would need to download all and generate hashes on our own
          - "historic" isn't mirrored; posted a question at #287
          - maybe cache (some) collections? (they don't overlap)
      */
      runCommand "texlive-${pname}-${version}"
        { # lots of derivations, not meant to be cached
          preferLocalBuild = true; allowSubstitutes = false;
          passthru = { inherit pname version; };
        }
        ( ''
          mkdir "$out"
          '' + lib.concatMapStrings unpackPkg (fastUnique (a: b: a.md5 < b.md5) pkgList)
        );

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
    poppler = poppler_nox; # otherwise depend on various X stuff
    ghostscript = ghostscriptX;
    harfbuzz = harfbuzz.override {
      withIcu = true; withGraphite2 = true;
    };
  };

  # TODO: replace by buitin once it exists
  fastUnique = comparator: list: with lib;
    let un_adj = l: if length l < 2 then l
      else optional (head l != elemAt l 1) (head l) ++ un_adj (tail l);
    in un_adj (lib.sort comparator list);

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
      (pname: attrs: combine { ${pname} = attrs; })
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
        paths = fastUnique (a: b: a < b) (map builtins.toPath (
          [ ]
          ++ lib.filter (pkgFilter "run"   ) metaPkg.pkgs.run
          ++ lib.filter (pkgFilter "doc"   ) metaPkg.pkgs.doc
          ++ lib.filter (pkgFilter "source") metaPkg.pkgs.source
        ));

        buildInputs = [ makeWrapper ];

        postBuild = ''
          cd "$out"
          mkdir -p ./bin
          ln -s '${bin}'/bin/{kpsewhich,kpseaccess} ./bin/

          export PATH="$out/bin:$out/share/texmf/scripts/texlive:${perl}/bin:$PATH"
          export TEXMFDIST="$out/share/texmf"
          export TEXMFSYSCONFIG="$out/share/texmf-config"
          export TEXMFSYSVAR="$out/share/texmf-var"
          export PERL5LIB="$out/share/texmf/scripts/texlive"
        '' +
          # patch texmf-dist -> texmf to be sure
          # TODO: cleanup the search paths incl. SELFAUTOLOC, and perhaps do lua actions?
          # tried inspiration from install-tl, sub do_texmf_cnf
        ''
          local cnfPath=./share/texmf/web2c/texmf.cnf
          local cnfOrig="$(realpath $cnfPath)"
          rm $cnfPath
          cat "$cnfOrig" | sed 's/texmf-dist/texmf/g' > $cnfPath
        '' +
        # wrap created executables with required env vars
        ''
          wrapBin() {
          for link in ./bin/*; do
            [ -L "$link" -a -x "$link" ] || continue # if not link, assume OK
            local target=$(readlink "$link")
            case "$target" in
              /*)
                echo -n "Wrapping '$link'"
                rm "$link"
                makeWrapper "$target" "$link" \
                  --prefix PATH : "$out/bin:${perl}/bin" \
                  --set TEXMFDIST "$out/share/texmf" \
                  --set TEXMFSYSCONFIG "$out/share/texmf-config" \
                  --set TEXMFSYSVAR "$out/share/texmf-var" \
                  --prefix PERL5LIB : "$out/share/texmf/scripts/texlive"

                # avoid using non-nix shebang in $target by calling interpreter
                if [[ "$(head -c 2 $target)" = "#!" ]]; then
                  local interp="$(head -n 1 $target | sed 's/^\#\! *//;s/ *$//')"
                  local newInterp=""
                  case "$interp" in
                    /bin/sh)
                      newInterp="$(echo -n ${stdenv.shell} | sed 's/bash$/sh/' )";;
                    /usr/bin/env\ perl|/usr/bin/perl)
                      newInterp='${perl}/bin/perl';;
                    '${perl}/bin/perl')
                      echo
                      continue;;
                    *)
                      echo "Unknown shebang '$interp' in '$target'"
                      false
                  esac
                  echo " and patching shebang '$interp'"
                  sed "s|^exec |exec $newInterp |" -i "$link"
                else
                  echo
                fi
                ;;
            esac
          done
          }
        '' +
        # texlive post-install actions
        ''
          mkdir -p "$out/share/texmf/scripts/texlive/"
          ln -s '${bin}/share/texmf-dist/scripts/texlive/TeXLive' "$out/share/texmf/scripts/texlive/"

          for tool in updmap fmtutil; do
            ln -s "$out/share/texmf/scripts/texlive/$tool."* "$out/bin/$tool"
          done
          ln -s fmtutil "$out/bin/mktexfmt"

          perl `type -P mktexlsr.pl` ./share/texmf
          texlinks.sh "$out/bin" && wrapBin
          perl `type -P fmtutil.pl` --sys --all | grep '^fmtutil' # too verbose
          #texlinks.sh "$out/bin" && wrapBin # may we need to run again?
          yes | perl `type -P updmap.pl` --sys --syncwithtrees || true
          yes | perl `type -P updmap.pl` --sys --syncwithtrees || true
        '' +
        # TODO: a context trigger https://www.preining.info/blog/2015/06/debian-tex-live-2015-the-new-layout/
          # http://wiki.contextgarden.net/ConTeXt_Standalone#Unix-like_platforms_.28Linux.2FMacOS_X.2FFreeBSD.2FSolaris.29
        ''
          ln -s texmf/doc/{man,info} "$out/share/"
        ''
        ;
      };
      # TODO: make TeX fonts visible by fontconfig: it should be enough to install an appropriate file
  }

