{ lib
, writeScript
, common-updater-scripts
}:
attrPath: { owner, repo, rev, ... }:
  # TODO:
  # * don't assume first entry is newer
  # * semver compare for newest, probably use something in lib.
  let
    releases = builtins.fetchurl "https://api.github.com/repos/${owner}/${repo}/releases";
    releaseJSON = builtins.fromJSON (builtins.readFile releases);
    tag = (builtins.head releaseJSON).tag_name;
    version = lib.removePrefix "v" tag;
  in
  writeScript "update-${attrPath}" ''
    ${common-updater-scripts}/bin/update-source-version ${attrPath} ${version}
  ''
