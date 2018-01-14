{ lib
, writeScript
, common-updater-scripts
}:
attrPath: { owner, repo, rev, ... }:
  let
    json = builtins.fetchurl "https://api.github.com/repos/${owner}/${repo}/releases";
    all_releases = builtins.fromJSON (builtins.readFile json);
    releases_unsorted = builtins.filter (r: !r.prerelease) all_releases;
    releases = lib.sort (a: b: lib.versionOlder b.tag_name a.tag_name) releases_unsorted;
    tag = (builtins.head releases).tag_name;
    version = lib.removePrefix "v" tag;
  in
  writeScript "update-${attrPath}" ''
    ${common-updater-scripts}/bin/update-source-version ${attrPath} ${version}
  ''
