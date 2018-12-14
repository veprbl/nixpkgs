{ rustPlatform, stdenv, fetchgit, makeWrapper, minijail, binutils-unwrapped }:

let

  arch = with stdenv.hostPlatform;
    if isArm then "arm"
    else if isx86_64 then "x86_64"
    else throw "no seccomp policy files available for host platform";

in

  rustPlatform.buildRustPackage rec {
    name = "crosvm-${version}";
    version = "R72-11316";

    src = fetchgit {
      url = "https://chromium.googlesource.com/chromiumos/platform/crosvm.git";
      rev = "510c1cfb46846a084a6316476602a658573ed93e";
      sha256 = "0p827lj2kxcg2x5b5y1fvif9bqhzmwkww4647g40hc0bxxfrzrql";
    };

    patches = [
      ./seccomp-policy-dir_env-var.patch
    ];

    cargoSha256 = "1k8wasgr537wwrcywql4ihrcff6s4w8py3x3bv2cipmxd4mdd57z";

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
