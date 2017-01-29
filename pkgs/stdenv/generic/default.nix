let lib = import ../../../lib; in lib.makeOverridable (

{ system, name ? "stdenv", preHook ? "", initialPath, cc, shell
, allowedRequisites ? null, extraAttrs ? {}, overrides ? (self: super: {}), config

, # The `fetchurl' to use for downloading curl and its dependencies
  # (see all-packages.nix).
  fetchurlBoot

, setupScript ? ./setup.sh

, extraBuildInputs ? []
, __stdenvImpureHostDeps ? []
, __extraImpureHostDeps ? []
, stdenvSandboxProfile ? ""
, extraSandboxProfile ? ""
}:

let
  ifDarwin = attrs: if system == "x86_64-darwin" then attrs else {};

  defaultNativeBuildInputs = extraBuildInputs ++
    [ ../../build-support/setup-hooks/move-docs.sh
      ../../build-support/setup-hooks/compress-man-pages.sh
      ../../build-support/setup-hooks/strip.sh
      ../../build-support/setup-hooks/patch-shebangs.sh
      ../../build-support/setup-hooks/multiple-outputs.sh
      ../../build-support/setup-hooks/move-sbin.sh
      ../../build-support/setup-hooks/move-lib64.sh
      ../../build-support/setup-hooks/set-source-date-epoch-to-latest.sh
      cc
    ];

  # `mkDerivation` wraps the builtin `derivation` function to
  # produce derivations that use this stdenv and its shell.
  #
  # See also:
  #
  # * https://nixos.org/nixpkgs/manual/#sec-using-stdenv
  #   Details on how to use this mkDerivation function
  #
  # * https://nixos.org/nix/manual/#ssec-derivation
  #   Explanation about derivations in general
  mkDerivation =
    { buildInputs ? []
    , nativeBuildInputs ? []
    , propagatedBuildInputs ? []
    , propagatedNativeBuildInputs ? []
    , crossConfig ? null
    , passthru ? {}
    , pos ? # position used in error messages and for meta.position
        (if attrs.meta.description or null != null
          then builtins.unsafeGetAttrPos "description" attrs.meta
          else builtins.unsafeGetAttrPos "name" attrs)
    , separateDebugInfo ? false
    , outputs ? [ "out" ]
    , __impureHostDeps ? []
    , __propagatedImpureHostDeps ? []
    , sandboxProfile ? ""
    , propagatedSandboxProfile ? ""
    , ... } @ attrs:
    let # Rename argumemnts to avoid cycles
      buildInputs__ = buildInputs;
      nativeBuildInputs__ = nativeBuildInputs;
      propagatedBuildInputs__ = propagatedBuildInputs;
      propagatedNativeBuildInputs__ = propagatedNativeBuildInputs;
    in let
      getNativeDrv = drv: drv.nativeDrv or drv;
      getCrossDrv = drv: drv.crossDrv or drv;
      nativeBuildInputs = map getNativeDrv nativeBuildInputs__;
      buildInputs = map getCrossDrv buildInputs__;
      propagatedBuildInputs = map getCrossDrv propagatedBuildInputs__;
      propagatedNativeBuildInputs = map getNativeDrv propagatedNativeBuildInputs__;
    in let

      outputs' =
        outputs ++
        (if separateDebugInfo then assert result.isLinux; [ "debug" ] else []);

      buildInputs' = lib.chooseDevOutputs buildInputs ++
        (if separateDebugInfo then [ ../../build-support/setup-hooks/separate-debug-info.sh ] else []);

      nativeBuildInputs' = lib.chooseDevOutputs nativeBuildInputs;
      propagatedBuildInputs' = lib.chooseDevOutputs propagatedBuildInputs;
      propagatedNativeBuildInputs' = lib.chooseDevOutputs propagatedNativeBuildInputs;

      # The meta attribute is passed in the resulting attribute set,
      # but it's not part of the actual derivation, i.e., it's not
      # passed to the builder and is not a dependency.  But since we
      # include it in the result, it *is* available to nix-env for queries.
      meta = { }
          # If the packager hasn't specified `outputsToInstall`, choose a default,
          # which is the name of `p.bin or p.out or p`;
          # if he has specified it, it will be overridden below in `// meta`.
          #   Note: This default probably shouldn't be globally configurable.
          #   Services and users should specify outputs explicitly,
          #   unless they are comfortable with this default.
        // { outputsToInstall =
          let
            outs = outputs'; # the value passed to derivation primitive
            hasOutput = out: builtins.elem out outs;
          in [( lib.findFirst hasOutput null (["bin" "out"] ++ outs) )];
        }
        // attrs.meta or {}
          # Fill `meta.position` to identify the source location of the package.
        // lib.optionalAttrs (pos != null)
          { position = pos.file + ":" + toString pos.line; }
        ;

      derivationArg =
        (removeAttrs attrs
          ["meta" "passthru" "crossAttrs" "pos"
           "__impureHostDeps" "__propagatedImpureHostDeps"
           "sandboxProfile" "propagatedSandboxProfile"])
        // (let
          computedSandboxProfile =
            lib.concatMap (input: input.__propagatedSandboxProfile or []) (extraBuildInputs ++ buildInputs' ++ nativeBuildInputs');
          computedPropagatedSandboxProfile =
            lib.concatMap (input: input.__propagatedSandboxProfile or []) (propagatedBuildInputs' ++ propagatedNativeBuildInputs');
          computedImpureHostDeps =
            lib.unique (lib.concatMap (input: input.__propagatedImpureHostDeps or []) (extraBuildInputs ++ buildInputs' ++ nativeBuildInputs'));
          computedPropagatedImpureHostDeps =
            lib.unique (lib.concatMap (input: input.__propagatedImpureHostDeps or []) (propagatedBuildInputs' ++ propagatedNativeBuildInputs'));
        in
        {
          builder = attrs.realBuilder or shell;
          args = attrs.args or ["-e" (attrs.builder or ./default-builder.sh)];
          stdenv = result;
          system = result.system;
          userHook = config.stdenv.userHook or null;
          __ignoreNulls = true;

          # Inputs built by the cross compiler.
          buildInputs = if crossConfig != null then buildInputs' else [];
          propagatedBuildInputs = if crossConfig != null then propagatedBuildInputs' else [];
          # Inputs built by the usual native compiler.
          nativeBuildInputs = nativeBuildInputs'
            ++ lib.optionals (crossConfig == null) buildInputs'
            ++ lib.optional
                (result.isCygwin
                  || (crossConfig != null && lib.hasSuffix "mingw32" crossConfig))
                ../../build-support/setup-hooks/win-dll-link.sh
            ;
          propagatedNativeBuildInputs = propagatedNativeBuildInputs' ++
            (if crossConfig == null then propagatedBuildInputs' else []);
        } // ifDarwin {
          # TODO: remove lib.unique once nix has a list canonicalization primitive
          __sandboxProfile =
          let profiles = [ extraSandboxProfile ] ++ computedSandboxProfile ++ computedPropagatedSandboxProfile ++ [ propagatedSandboxProfile sandboxProfile ];
              final = lib.concatStringsSep "\n" (lib.filter (x: x != "") (lib.unique profiles));
          in final;
          __propagatedSandboxProfile = lib.unique (computedPropagatedSandboxProfile ++ [ propagatedSandboxProfile ]);
          __impureHostDeps = computedImpureHostDeps ++ computedPropagatedImpureHostDeps ++ __propagatedImpureHostDeps ++ __impureHostDeps ++ __extraImpureHostDeps ++ [
            "/dev/zero"
            "/dev/random"
            "/dev/urandom"
            "/bin/sh"
          ];
          __propagatedImpureHostDeps = computedPropagatedImpureHostDeps ++ __propagatedImpureHostDeps;
        } // (if outputs' != [ "out" ] then {
          outputs = outputs';
        } else { }));
    in

      lib.addPassthru
        (derivation
            (lib.addMetaCheckInner config (attrs.meta or {}) derivationArg))
        ( {
            overrideAttrs = f: mkDerivation (attrs // (f attrs));
            inherit meta passthru;
          } //
          # Pass through extra attributes that are not inputs, but
          # should be made available to Nix expressions using the
          # derivation (e.g., in assertions).
          passthru);

  # The stdenv that we are producing.
  result =
    derivation (
    (if isNull allowedRequisites then {} else { allowedRequisites = allowedRequisites ++ defaultNativeBuildInputs; }) //
    {
      inherit system name;

      builder = shell;

      args = ["-e" ./builder.sh];

      setup = setupScript;

      inherit preHook initialPath shell defaultNativeBuildInputs;
    }
    // ifDarwin {
      __sandboxProfile = stdenvSandboxProfile;
      __impureHostDeps = __stdenvImpureHostDeps;
    })

    // rec {

      meta = {
        description = "The default build environment for Unix packages in Nixpkgs";
        platforms = lib.platforms.all;
      };

      # Utility flags to test the type of platform.
      isDarwin = system == "x86_64-darwin";
      isLinux = system == "i686-linux"
             || system == "x86_64-linux"
             || system == "powerpc-linux"
             || system == "armv5tel-linux"
             || system == "armv6l-linux"
             || system == "armv7l-linux"
             || system == "aarch64-linux"
             || system == "mips64el-linux";
      isGNU = system == "i686-gnu"; # GNU/Hurd
      isGlibc = isGNU # useful for `stdenvNative'
             || isLinux
             || system == "x86_64-kfreebsd-gnu";
      isSunOS = system == "i686-solaris"
             || system == "x86_64-solaris";
      isCygwin = system == "i686-cygwin"
              || system == "x86_64-cygwin";
      isFreeBSD = system == "i686-freebsd"
               || system == "x86_64-freebsd";
      isOpenBSD = system == "i686-openbsd"
               || system == "x86_64-openbsd";
      isi686 = system == "i686-linux"
            || system == "i686-gnu"
            || system == "i686-freebsd"
            || system == "i686-openbsd"
            || system == "i686-cygwin"
            || system == "i386-sunos";
      isx86_64 = system == "x86_64-linux"
              || system == "x86_64-darwin"
              || system == "x86_64-freebsd"
              || system == "x86_64-openbsd"
              || system == "x86_64-cygwin"
              || system == "x86_64-solaris";
      is64bit = system == "x86_64-linux"
             || system == "x86_64-darwin"
             || system == "x86_64-freebsd"
             || system == "x86_64-openbsd"
             || system == "x86_64-cygwin"
             || system == "x86_64-solaris"
             || system == "mips64el-linux";
      isMips = system == "mips-linux"
            || system == "mips64el-linux";
      isArm = system == "armv5tel-linux"
           || system == "armv6l-linux"
           || system == "armv7l-linux";
      isAarch64 = system == "aarch64-linux";
      isBigEndian = system == "powerpc-linux";

      # Whether we should run paxctl to pax-mark binaries.
      needsPax = isLinux;

      inherit mkDerivation;

      # For convenience, bring in the library functions in lib/ so
      # packages don't have to do that themselves.
      inherit lib;

      inherit fetchurlBoot;

      inherit overrides;

      inherit cc;
    }

    # Propagate any extra attributes.  For instance, we use this to
    # "lift" packages like curl from the final stdenv for Linux to
    # all-packages.nix for that platform (meaning that it has a line
    # like curl = if stdenv ? curl then stdenv.curl else ...).
    // extraAttrs;

in result)
