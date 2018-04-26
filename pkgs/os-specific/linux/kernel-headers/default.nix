{ stdenvNoCC, lib, buildPackages
, buildPlatform, hostPlatform
, fetchurl, perl
}:

assert hostPlatform.isLinux;

let
  common = { version, sha256, patches ? null }: stdenvNoCC.mkDerivation {
    name = "linux-headers-${version}";

    src = fetchurl {
      url = "mirror://kernel/linux/kernel/v4.x/linux-${version}.tar.xz";
      inherit sha256;
    };

    ARCH = hostPlatform.platform.kernelArch;

    # It may look odd that we use `stdenvNoCC`, and yet explicit depend on a cc.
    # We do this so we have a build->build, not build->host, C compiler.
    depsBuildBuild = [ buildPackages.stdenv.cc ];
    nativeBuildInputs = [ perl ];

    extraIncludeDirs = lib.optional hostPlatform.isPowerPC ["ppc"];

    # "patches" array defaults to 'null' to avoid changing hash
    # and causing mass rebuild
    inherit patches;

    buildPhase = ''
      make mrproper headers_check SHELL=bash
    '';

    installPhase = ''
      make INSTALL_HDR_PATH=$out headers_install

      # Some builds (e.g. KVM) want a kernel.release.
      mkdir -p $out/include/config
      echo "${version}-default" > $out/include/config/kernel.release
    '';

    meta = with lib; {
      description = "Header files and scripts for Linux kernel";
      license = licenses.gpl2;
      platforms = platforms.linux;
    };
  };
in {

  linuxHeaders = common {
    version = "4.16";
    sha256 = "1f91pf3lq3kmbg82k4v8bwxcl4r4iaixrx6nsmrh4flz7j7drxk3";

    patches = [
      # Limit glibc-specific workaround (including sysinfo from kernel) to glibc
      (fetchurl {
        url = https://raw.githubusercontent.com/openwrt/openwrt/e3c43ade0bae9491aeea50fa361e846bb5002dc0/target/linux/generic/pending-4.14/270-uapi-kernel.h-glibc-specific-inclusion-of-sysinfo.h.patch;
        sha256 = "1knhg8hf4k1ylk8959421amsbw5myypbbmiqj1yr8k3qs5sw2ais";
      })
    ];
  };
}
