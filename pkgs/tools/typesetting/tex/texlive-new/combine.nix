params: with params;
# combine =
args@{ pkgFilter ? (pkg: pkg.tlType == "run" || pkg.tlType == "bin" || pkg.pname == "core"), ... }:
let
  pkgSet = removeAttrs args ["pkgFilter"] // {
    # include a fake "core" package
    core.pkgs = [
      (bin.core.doc // { pname = "core"; tlType = "doc"; })
      (bin.core.out // { pname = "core"; tlType = "bin"; })
    ];
  };
  pkgList = rec {
    all = lib.filter pkgFilter (combinePkgs pkgSet);
    splitBin = lib.partition (p: p.tlType == "bin") all;
    bin = mkUniquePkgs splitBin.right;
    nonbin = mkUniquePkgs splitBin.wrong;
  };

  mkUniquePkgs = pkgs: fastUnique (a: b: a < b)
    # here we deal with those dummy packages needed for hyphenation filtering
    (map (p: if lib.isDerivation p then builtins.toPath p else "") pkgs);
in buildEnv {
  name = "texlive-combined-${bin.version}";

  extraPrefix = "/share/texmf";

  ignoreCollisions = false;
  paths = pkgList.nonbin;

  buildInputs = [ makeWrapper ];

  postBuild = ''
    cd "$out"
    mkdir -p ./bin
  '' +
    lib.concatMapStrings
      (path: ''
        for f in '${path}'/bin/*; do
          ln -s "$f" ./bin/
        done
      '')
      pkgList.bin
    +
  ''
    export PATH="$out/bin:$out/share/texmf/scripts/texlive:${perl}/bin:$PATH"
    export TEXMFCNF="$out/share/texmf/web2c"
    export TEXMFDIST="$out/share/texmf"
    export TEXMFSYSCONFIG="$out/share/texmf-config"
    export TEXMFSYSVAR="$out/share/texmf-var"
    export PERL5LIB="$out/share/texmf/scripts/texlive"
  '' +
    # patch texmf-dist -> texmf to be sure
    # TODO: cleanup the search paths incl. SELFAUTOLOC, and perhaps do lua actions?
    # tried inspiration from install-tl, sub do_texmf_cnf
  ''
    (
      cd ./share/texmf/web2c/
      local cnfOrig="$(realpath ./texmf.cnf)"
      rm ./texmf.cnf
      cat "$cnfOrig" | sed 's/texmf-dist/texmf/g' > ./texmf.cnf

      rm updmap.cfg
    )
  '' +
    # updmap.cfg seems like not needing changes

    # now filter hyphenation patterns, in a hacky way ATM
  ''
    (
      if [[ -e ./share/texmf/tex/generic/config/language.dat ]]; then
        cd ./share/texmf/tex/generic/config/
        cnfOrig="$(realpath ./language.dat)"
        rm ./language.dat
        local script='${
          lib.concatMapStrings (pkg: "/^\% from ${pkg.pname}/,/^\%/p;\n")
            pkgList.splitBin.wrong
        }'
        cat "$cnfOrig" | sed -n "$script" > ./language.dat
      fi
    )
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
            --set TEXMFCNF "$out/share/texmf/web2c" \
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
              /nix/store/*)
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
    ln -s '${bin.core.out}/share/texmf-dist/scripts/texlive/TeXLive' "$out/share/texmf/scripts/texlive/"

    for tool in updmap; do
      ln -sf "$out/share/texmf/scripts/texlive/$tool."* "$out/bin/$tool"
    done
  '' +
    # now hack to preserve "$0" for mktexfmt
  ''
    cp "$out"/share/texmf/scripts/texlive/fmtutil.pl "$out/bin/fmtutil"
    patchShebangs "$out/bin/fmtutil"
    ln -sf fmtutil "$out/bin/mktexfmt"

    perl `type -P mktexlsr.pl` ./share/texmf
    texlinks.sh "$out/bin" && wrapBin
    perl `type -P fmtutil.pl` --sys --refresh | grep '^fmtutil' # too verbose
    #texlinks.sh "$out/bin" && wrapBin # may we need to run again?
    perl `type -P updmap.pl` --sys --syncwithtrees --force
    perl `type -P mktexlsr.pl` ./share/texmf-* # to make sure
  '' +
  # TODO: a context trigger https://www.preining.info/blog/2015/06/debian-tex-live-2015-the-new-layout/
    # http://wiki.contextgarden.net/ConTeXt_Standalone#Unix-like_platforms_.28Linux.2FMacOS_X.2FFreeBSD.2FSolaris.29

    # I would just create links from "$out"/share/{man,info},
    #   but buildenv has problems with merging symlinks with directories;
    #   note: it's possible we might need deepen the work-around to man/*.
  ''
    for d in {man,info}; do
      [[ -e "./share/texmf/doc/$d" ]] || continue;
      (
        mkdir -p "./share/$d" && cd "./share/$d"
        ln -s -t . ../texmf/doc/"$d"/*
      )
    done
  ''
    + bin.cleanBrokenLinks
  ;
}
# TODO: make TeX fonts visible by fontconfig: it should be enough to install an appropriate file
#       similarly, deal with xe(la)tex font visibility?

