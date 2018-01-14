{ common-updater-scripts
, writeScript
, fetchFromGitHub
}:
{ owner, repo, rev, ... } @ args:

(fetchFromGitHub args) // {
  updateScript = { attrPath ? repo }: writeScript "update-${attrPath}" ''
      version=$(nix-instantiate --eval --strict ${./update-check.nix} --argstr owner ${owner} --argstr repo ${repo})
      echo version=$version
      echo ${common-updater-scripts}/bin/update-source-version ${attrPath} ''${version}
    '';
}
