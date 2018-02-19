{ stdenv
, lib
, fetchurl
, isJuliaPackage
, buildJuliaPackage
, parseRequires
}:

let
  isRelease = version:
  with version.ver; prerelease == [] && build == [];
  # 'ver' is supposed to be a set of version numbers such as
  # { major = 1; minor = 0; patch = 0; prerelease = ["alpha" 0], build = [123] }.

  # The above example should be converted to "1.0.0-alpha.0+123".
  toVersionString = ver:
  let
    inherit (lib.mapAttrs (_: v: toString v) ver) major minor patch;
    prerelease = builtins.concatStringsSep "." (map toString ver.prerelease);
    build = builtins.concatStringsSep "." (map toString ver.build);
  in
  "${major}.${minor}.${patch}"
  + lib.optionalString (prerelease != "") "-${prerelease}"
  + lib.optionalString (build != "") "+${build}";

  matchVersion = versionString: version:
  versionString == toVersionString version.ver;

in

{ pname
, url
, versions
, version ? null
}:

let
  newestRelease = lib.findFirst isRelease null versions;

  identifiedVersion =
  let error = abort "invalid version of ${pname}: ${version}"; in
  if isNull version
  then newestRelease
  else lib.findFirst (matchVersion version) error versions;

  propagatedBuildInputs = parseRequires identifiedVersion.requires;

in buildJuliaPackage {
  inherit pname;
  version = toVersionString identifiedVersion.ver;

  src = fetchurl {
    url = "${url}/archive/${identifiedVersion.rev}.tar.gz";
    inherit (identifiedVersion) sha256;
  };

  inherit propagatedBuildInputs;
}
