{ fetchFromGitHub, buildGoPackage, clang_39 }:
buildGoPackage rec {
  name = "navc-${version}";
  version = "2016-04-30";
  src = fetchFromGitHub {
    owner = "google";
    repo = "navc";
    rev = "9800a1dcf47";
    sha256 = "1f774qhapwpc9dl46zkps0jirj8vdicazxxn4c83z16c3dw6jmng";
  };

  postPatch = ''
    for f in {parse,symbols-db}.go; do
      substituteInPlace "$f" --replace "github.com/go-clang/v3.6/clang" \
                                       "github.com/go-clang/v3.9/clang"
    done
    set -x
  '';

  goPackagePath = "github.com/google/navc";

  buildInputs = [ clang_39.cc ];

  NIX_CFLAGS_COMPILE = [ "-Wno-deprecated-declarations" ];
  GODEBUG = [ "cgocheck=0" ];

  goDeps = ./deps.nix;
}
