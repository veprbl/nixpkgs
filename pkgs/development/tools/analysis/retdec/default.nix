{ stdenv,
fetchFromGitHub, fetchurl, fetchzip,
# Native build inputs
cmake, pkgconfig,
autoreconfHook,
bison, flex,
groff,
perl,
python3,
# Runtime tools
bash, # specifically requires >= 4, ensure we have it
bc,
coreutils,
graphviz,
time,
upx,
# Build inputs
ncurses,
openssl,
libffi,
libxml2,
zlib,
# PE (Windows) data, huge space savings if not needed
withPEPatterns ? false,
}:

let
  version = "2018-01-31";
  support-version = "2017-12-15";

  retdec-support = fetchzip {
    url = "https://github.com/avast-tl/retdec-support/releases/download/${support-version}/retdec-support_${support-version}.tar.xz";
    sha256 = if withPEPatterns then "16pmrjmlr3sacf4dasi7lxhbsv3fwp78wbr4s48y01r99jlsnbqg"
                               else "0g1hklrpbsmsy9y4jcrlc221lk42ad607ydcrd8p77nr885kqyzg";
    # Removing PE signatures reduces this from 3.8GB -> 642MB (uncompressed)
    extraPostFetch = stdenv.lib.optionalString (!withPEPatterns) ''
      rm -rf $out/generic/yara_patterns/static-code/pe
    '';
    stripRoot = false;
  };

  deps = (import ./deps.nix);

  genPatchCmd = n: v: ''
    echo "Patching in prefetched archive for '${n}'..."
    f=deps/${n}/CMakeLists.txt
    grep -q "${v.sha256}" $f || (echo "ERROR: expected hash not found!"; exit 1)
    sed -i -e 's|URL .*|URL ${fetchurl v}|' deps/${n}/CMakeLists.txt
  '';

  patch_to_use_prefetched_deps = with stdenv.lib;
    concatStrings (mapAttrsToList genPatchCmd deps)
    # Copy yaracpp source into tree instead of using as external project,
    # avoids difficulties re-describing transitive dependencies on yara.
    # Replace that brittle boilerplate with simple use of pkgconfig + import.
    + ''
    rm deps/yaracpp -rf
    cp -a ${yaracpp_src} deps/yaracpp

    chmod -R u+w deps/yaracpp
    cat > deps/yaracpp/deps/CMakeLists.txt <<EOF
      include(FindPkgConfig)
      pkg_check_modules(REQUIRED IMPORTED_TARGET yara)
    EOF

    substituteInPlace deps/yaracpp/src/CMakeLists.txt \
      --replace libyara yara
  '';

  yara = import ./yara.nix { inherit stdenv fetchurl autoreconfHook; };
  yaracpp_src = fetchzip {
    url = "https://github.com/avast-tl/yaracpp/archive/v1.0.1.zip";
    sha256 = "1gh8rv4p2pnl6dk7rch6p4lkcyg9v1l42mvrwl724iwa56dywri8";
  };

  binPath = stdenv.lib.makeBinPath [ bash bc coreutils graphviz time upx ];

in stdenv.mkDerivation rec {
  name = "retdec-${version}";
  inherit version;

  src = fetchFromGitHub {
    owner = "avast-tl";
    repo = "retdec";
    rev = "6489bd2d36a090fbdc645aa864f0782a23c9555b";
    sha256 = "1mmcv9adl8ksdndbpi1yy3zq7hy8i47cpcajfxr8dyk2hq2sc7zc";
  };

  nativeBuildInputs = [
    cmake pkgconfig
    bison flex
    groff perl
    python3
  ];

  buildInputs = [ libffi libxml2 ncurses openssl yara zlib ];

  postPatch = patch_to_use_prefetched_deps + ''
    cat > cmake/install-share.sh <<EOF
      #!/bin/sh
      mkdir -p $out/share/retdec/
      ln -s ${retdec-support} $out/share/retdec/support
    EOF
    chmod +x cmake/*.sh
    patchShebangs cmake/*.sh
  '';

  postInstall = ''
    sed -i -e '2iexport PATH=${binPath}''${PATH:+:}$PATH' $out/bin/*.sh
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A retargetable machine-code decompiler based on LLVM";
    homepage = https://retdec.com;
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
  };
}
