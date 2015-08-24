{ stdenv, lib, fetchurl, runCommand, buildEnv
, callPackage, ghostscriptX, harfbuzz
}:
let
  tl-clean = removeAttrs (import ./pkgs.nix tl-flatDeps) [ "trash" ];
  tl-flatDeps = lib.mapAttrs flatDeps tl-clean;

  flatDeps = name: attrs:
    let
      # list of tarballs to be contained;
      # we could do sorted list merging, but they're represented as arrays...
      /*
      srcs_dup = lib.zipAttrsWith
        (lib.mapAttrsToList (_name: dep: dep) (attrs.deps or []));
      srcs = lib.unique srcs_dup; # TODO: optimize
      */
    in
      if isSinglePackage name attrs
      then let mkPkgV = mkPkg (attrs.version or bin.version);
        in {
          # TL pkg contains three lists of packages: runtime files, docs, and sources
          pkgs.run = [ (mkPkgV name attrs.md5.run) ];
          pkgs.doc = lib.optional (attrs.md5 ? "doc")
            (mkPkgV "${name}.doc" attrs.md5.doc);
          pkgs.src = lib.optional (attrs.md5 ? "src")
            (mkPkgV "${name}.src" attrs.md5.src);
        }
      else
        combinePkgs attrs.deps;

  mkPkg = version: name: md5:
    let src = fetchurl {
        # TODO: some src URLs have "source" instead of "src". Ask upstream?
        url = "http://mirror.ctan.org/systems/texlive/tlnet/archive/${name}.tar.xz";
        inherit md5;
      };
    in runCommand "texlive-${name}-${version}"
        { preferLocalBuild = true; passthru = { inherit version; pName = name; }; }
        ''
          mkdir "$out"
          tar -xf '${src}' -C "$out" --anchored --exclude=tlpkg \
            --strip-components=1 --keep-old-files
        '';

  isSinglePackage = name: _attrs:
    (!lib.hasPrefix "collection-" name) && (!lib.hasPrefix "scheme-" name);

  # combine a set of TL packages into a single TL meta-package
  combinePkgs = pkgSet:
    let getFlat = attrName: lib.unique (lib.concatLists
        (map (dep: lib.getAttr attrName dep.pkgs)
          (lib.mapAttrsToList (_n: a: a) pkgSet))
      );
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

    schemes.basic = combine { pkgSet = { inherit (tl-flatDeps) scheme-basic; }; };

    combine = { pkgSet, pkgFilter ? (type: _n: type == "run") }:
      let metaPkg = combinePkgs pkgSet;
      in buildEnv {
        name = "texlive-combined-${bin.version}";

        extraPrefix = "/share/texmf";
        paths =
          lib.filter (pkgFilter "run") metaPkg.pkgs.run ++
          lib.filter (pkgFilter "doc") metaPkg.pkgs.doc ++
          lib.filter (pkgFilter "src") metaPkg.pkgs.src;

        postBuild = ''
          cd "$out"
          mkdir -p ./bin
          ln -s '${bin}'/bin/* ./bin/

          PATH="$out/bin:$PATH"
          mktexlsr ./share/texmf
          updmap --sys --syncwithtrees
        '';
      };
  }
  /*
  tl-srcs // {
  }
  #*/


