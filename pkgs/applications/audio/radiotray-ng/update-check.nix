{ owner, repo }:
let
  lib = import <nixpkgs/lib>;
  json = builtins.fetchurl "https://api.github.com/repos/${owner}/${repo}/releases";
  all_releases = builtins.fromJSON (builtins.readFile json);
  releases_unsorted = builtins.filter (r: !r.prerelease) all_releases;
  releases = lib.sort (a: b: lib.versionOlder (asVersion b.tag_name) (asVersion a.tag_name)) releases_unsorted;
  tag = (builtins.head releases).tag_name;

  isVersion = v: (builtins.parseDrvName "x-${v}") == { name = "x"; version = v; };

  asVersion = v:
    let
      parsedV = (builtins.parseDrvName v).version;
      noVprefix = lib.removePrefix "v" v;
    in
       if isVersion v then v
       else if (noVprefix != v) then asVersion noVprefix
       else asVersion parsedV;

in asVersion tag

