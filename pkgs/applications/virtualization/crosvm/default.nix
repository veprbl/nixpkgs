{ rustPlatform, stdenv, fetchgit, makeWrapper, minijail, binutils-unwrapped }:

let

  arch = with stdenv.hostPlatform;
    if isArm then "arm"
    else if isx86_64 then "x86_64"
    else throw "no seccomp policy files available for host platform";

in

  rustPlatform.buildRustPackage rec {
    name = "crosvm-${version}";
    version = "R73-11647.B";

    src = fetchgit {
      url = "https://chromium.googlesource.com/chromiumos/platform/crosvm.git";
      rev = "1be25dc3d2ce8afe41d0fe7fe7b157c3f1787b50"; # "release-${version}" branch
      sha256 = "0w214d49agw10hvrxapsp9rqrv737q644kdnidglwlqpc0879yx8";
    };

    patches = [
      ./seccomp-policy-dir_env-var.patch
    ];

    cargoSha256 = "0480a0i7glawvdhkrpbymhh6l1ymhmhj500835234jycanjkank7";

    buildInputs = [ makeWrapper minijail binutils-unwrapped ];

    postInstall = ''
      mkdir -p $out/share/policy/
      cp seccomp/${arch}/* $out/share/policy/
      wrapProgram $out/bin/crosvm --set CROSVM_SECCOMP_POLICY_DIR $out/share/policy/
    '';

    meta = with stdenv.lib; {
      description = "A secure virtual machine monitor for KVM";
      homepage = https://chromium.googlesource.com/chromiumos/platform/crosvm/;
      license = licenses.bsd3;
      platforms = [ "arm-linux" "x86_64-linux" ];
    };
  }
