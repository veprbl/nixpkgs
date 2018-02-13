{ buildJuliaPackage
# , packages
, fetchgit
}:

{ pkg
, version
}:

let
  src = fetchgit {
    url = pkg.url;
    sha1 = version.sha1;
    rev = ;
  };

in buildJuliaPackage {
  inherit src;
}
