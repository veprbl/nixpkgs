let
  lib = import ./default.nix;
in rec {

  # Extend attributes to be passed to derivation (or similar) with a check
  # for brokenness, license, etc.  Throw a descriptive error if the check fails.
  # Note: no dependencies are checked in this step, but this should be done before
  #   applying the `derivation` primitive in order to "propagate to dependants".
  addMetaCheckInner = config: meta: drv:
    let
      v = checkMetaValidity { inherit meta config; inherit (drv) system; };
    in
      # As a compromise, do the check when evaluating the name attribute;
      #   the intention is to also catch any attempt to show in nix-env -qa,
      #   while allowing to query meta (surprisingly even --no-name doesn't break that).
      drv // {
        name = if v.valid then drv.name
          else throwEvalHelp (
            {
              inherit (v) reason errormsg;
              name = drv.name or "«name-missing»";
              position = meta.position or "«unknown-file»";
            });
      };

  # Make sure the dependencies are evaluted when accessing the name.
  # The input is a derivation, i.e. *after* applying the `derivation` primitive.
  addMetaCheckOuter = drv:
    drv // { name = assert drv.outPath != null; drv.name; };

  # Throw a descriptive error message for a failed evaluation check.
  throwEvalHelp = { reason, errormsg, name, position }:
    # uppercase the first character of string s
    let up = s: with lib;
      (toUpper (substring 0 1 s)) + (substring 1 (stringLength s) s);
    in
    assert builtins.elem reason [ "unfree" "broken" "blacklisted" ];

    throw ("Package ‘${name}’ in ${position} ${errormsg}, refusing to evaluate."
    + (lib.strings.optionalString (reason != "blacklisted") ''

      a) For `nixos-rebuild` you can set
        { nixpkgs.config.allow${up reason} = true; }
      in configuration.nix to override this.

      b) For `nix-env`, `nix-build`, `nix-shell` or any other Nix command you can add
        { allow${up reason} = true; }
      to ~/.nixpkgs/config.nix.
    ''));

  # Check if a derivation is valid, that is whether it passes checks for
  # e.g brokenness or license.
  #
  # Return { valid: Bool } and additionally
  # { reason: String; errormsg: String } if it is not valid, where
  # reason is one of "unfree", "blacklisted" or "broken".
  checkMetaValidity = { meta, config, system }: let

    whitelist = config.whitelistedLicenses or [];
    blacklist = config.blacklistedLicenses or [];

    onlyLicenses = list:
      lib.lists.all (license:
        let l = lib.licenses.${license.shortName or "BROKEN"} or false; in
        if license == l then true else
          throw ''‘${showLicense license}’ is not an attribute of lib.licenses''
      ) list;

    areLicenseListsValid =
      if lib.mutuallyExclusive whitelist blacklist then
        assert onlyLicenses whitelist; assert onlyLicenses blacklist; true
      else
        throw "whitelistedLicenses and blacklistedLicenses are not mutually exclusive.";

    hasWhitelistedLicense = assert areLicenseListsValid; attrs:
      meta ? license && builtins.elem meta.license whitelist;

    hasBlacklistedLicense = assert areLicenseListsValid; attrs:
      meta ? license && builtins.elem meta.license blacklist;

    isUnfree = licenses: lib.lists.any (l:
      !l.free or true || l == "unfree" || l == "unfree-redistributable") licenses;

    allowUnfree = config.allowUnfree or false || builtins.getEnv "NIXPKGS_ALLOW_UNFREE" == "1";

    # Alow granular checks to allow only some unfree packages
    # Example:
    # {pkgs, ...}:
    # {
    #   allowUnfree = false;
    #   allowUnfreePredicate = (x: pkgs.lib.hasPrefix "flashplayer-" x.name);
    # }
    allowUnfreePredicate = config.allowUnfreePredicate or (x: false);

    # Check whether unfree packages are allowed and if not, whether the
    # package has an unfree license and is not explicitely allowed by the
    # `allowUNfreePredicate` function.
    hasDeniedUnfreeLicense = meta:
      !allowUnfree &&
      meta ? license &&
      isUnfree (lib.lists.toList meta.license) &&
      !allowUnfreePredicate meta;

    showLicense = license: license.shortName or "unknown";

    allowBroken = config.allowBroken or false || builtins.getEnv "NIXPKGS_ALLOW_BROKEN" == "1";

    in # compose the result
      if hasDeniedUnfreeLicense meta && !(hasWhitelistedLicense meta) then
        { valid = false; reason = "unfree"; errormsg = "has an unfree license (‘${showLicense meta.license}’)"; }
      else if hasBlacklistedLicense meta then
        { valid = false; reason = "blacklisted"; errormsg = "has a blacklisted license (‘${showLicense meta.license}’)"; }
      else if !allowBroken && meta.broken or false then
        { valid = false; reason = "broken"; errormsg = "is marked as broken"; }
      else if !allowBroken && meta.platforms or null != null && !lib.lists.elem system meta.platforms then
        { valid = false; reason = "broken"; errormsg = "is not supported on ‘${system}’"; }
      else { valid = true; };
  # ^ checkMetaValidity

}

