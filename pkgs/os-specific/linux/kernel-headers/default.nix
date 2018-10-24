{ stdenvNoCC, lib, buildPackages
, fetchurl, fetchpatch, perl
, elf-header
}:

let
  common = { version, sha256, patches ? [] }: stdenvNoCC.mkDerivation {
    name = "linux-headers-${version}";

    src = fetchurl {
      url = "mirror://kernel/linux/kernel/v4.x/linux-${version}.tar.xz";
      inherit sha256;
    };

    ARCH = stdenvNoCC.hostPlatform.platform.kernelArch or (throw "missing kernelArch");

    # It may look odd that we use `stdenvNoCC`, and yet explicit depend on a cc.
    # We do this so we have a build->build, not build->host, C compiler.
    depsBuildBuild = [ buildPackages.stdenv.cc ];
    nativeBuildInputs = [ perl elf-header ];

    hardeningDisable = lib.optional stdenvNoCC.buildPlatform.isDarwin "format";

    extraIncludeDirs = lib.optional stdenvNoCC.hostPlatform.isPowerPC ["ppc"];

    # "patches" array defaults to 'null' to avoid changing hash
    # and causing mass rebuild
    inherit patches;

    makeFlags = [
      "SHELL=bash"
      # Avoid use of runtime build->host compilers for checks. These
      # checks only cared to work around bugs in very old compilers, so
      # these changes should be safe.
      "cc-version:=9999"
      "cc-fullversion:=999999"
      # `$(..)` expanded by make alone
      "HOSTCC:=$(BUILD_CC)"
      "HOSTCXX:=$(BUILD_CXX)"
    ];

    # Skip clean on darwin, case-sensitivity issues.
    buildPhase = lib.optionalString (!stdenvNoCC.buildPlatform.isDarwin) ''
      make mrproper $makeFlags
    ''
    # For some reason, doing `make install_headers` twice, first without
    # INSTALL_HDR_PATH=$out then with, is neccessary to get this to work
    # for darwin cross. @Ericson2314 has no idea why.
    + ''
      make headers_install $makeFlags
    '';

    checkPhase = ''
      make headers_check $makeFlags
    '';

    installPhase = ''
      make headers_install INSTALL_HDR_PATH=$out $makeFlags

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
    version = "4.19";
    sha256 = "18a92z17alh5kkvjv7l9z8wk5jgdb6raawdfkpwx9bi8amjzas0c";
    patches = [
       ./no-relocs.patch # for building x86 kernel headers on non-ELF platforms
       ./no-dynamic-cc-version-check.patch # so we can use `stdenvNoCC`, see `makeFlags` above
    ];
  };
}
