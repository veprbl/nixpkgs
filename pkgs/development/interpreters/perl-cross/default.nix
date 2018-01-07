{ lib, stdenv, buildPackages, fetchurlBoot }:

with lib;
let

  libc = if stdenv.cc.libc or null != null then stdenv.cc.libc else "/usr";
  libcInc = lib.getDev libc;
  libcLib = lib.getLib libc;
  common = {perlVersion, perlSha256}: stdenv.mkDerivation rec {
    name = "perl-cross";
    version = perlVersion;
    crossVersion = "1.1.8";

    srcs = [
      (fetchurlBoot {
        url = "mirror://cpan/src/5.0/perl-${perlVersion}.tar.gz";
        sha256 = perlSha256;
      })

      (fetchurlBoot {
        url = "https://github.com/arsv/perl-cross/releases/download/${crossVersion}/${name}-${crossVersion}.tar.gz";
        sha256 = "072j491rpz2qx2sngbg4flqh4lx5865zyql7b9lqm6s1kknjdrh8";
      })
    ];
    sourceRoot = "perl-${perlVersion}";

    nativeBuildInputs = [ buildPackages.stdenv.cc ];

    postUnpack = "cp -R perl-cross-${crossVersion}/* perl-${perlVersion}";

    configurePlatforms = [ "build" "host" "target" ];

    # TODO: Add a "dev" output containing the header files.
    outputs = [ "out" "man" "devdoc" ];
    setOutputFlags = false;

    patches =
      [ ]
      # Do not look in /usr etc. for dependencies.
      ++ optional (versionOlder version "5.26") ../perl/no-sys-dirs.patch
      ++ optional (versionAtLeast version "5.26") ../perl/no-sys-dirs-5.26.patch
      ++ optional (versionAtLeast version "5.24") (
        # Fix parallel building: https://rt.perl.org/Public/Bug/Display.html?id=132360
        fetchurlBoot {
          url = "https://rt.perl.org/Public/Ticket/Attachment/1502646/807252/0001-Fix-missing-build-dependency-for-pods.patch";
          sha256 = "1bb4mldfp8kq1scv480wm64n2jdsqa3ar46cjp1mjpby8h5dr2r0";
        })
    ;

    postPatch = ''
      pwd="$(type -P pwd)"
      substituteInPlace dist/PathTools/Cwd.pm \
        --replace "/bin/pwd" "$pwd"

      substituteInPlace cnf/configure_tool.sh --replace "cc -E -P" "cc -E"
    '';

    configureFlags = [
      "-Uinstallusrbinperl"
      "-Dinstallstyle=lib/perl5"
      "-Duseshrplib"
      "-Dlocincpth=${libcInc}/include"
      "-Dloclibpth=${libcLib}/lib"
      "-Dlibpth=\"\""
      "-Dglibpth=\"\""
      "-Dusethreads"
    ];

    # Doesn't work with perl-cross, even with patch
    enableParallelBuilding = false;

    preConfigure = optionalString (stdenv.isArm || stdenv.isMips) ''
        configureFlagsArray=(-Dldflags="-lm -lrt")
      '' + optionalString stdenv.isDarwin ''
        substituteInPlace hints/darwin.sh --replace "env MACOSX_DEPLOYMENT_TARGET=10.3" ""
      '';

    preBuild = optionalString (!(stdenv ? cc && stdenv.cc.nativeTools))
      ''
        # Make Cwd work on NixOS (where we don't have a /bin/pwd).
        substituteInPlace dist/PathTools/Cwd.pm --replace "'/bin/pwd'" "'$(type -tP pwd)'"
      '';

    setupHook = ../perl/setup-hook.sh;

    passthru.libPrefix = "lib/perl5/site_perl";

    # TODO: it seems like absolute paths to some coreutils is required.
    postInstall =
      ''
        # Remove dependency between "out" and "man" outputs.
        rm "$out"/lib/perl5/*/*/.packlist

        # Remove dependencies on glibc and gcc
        sed "/ *libpth =>/c    libpth => ' '," \
          -i "$out"/lib/perl5/*/*/Config.pm
        # TODO: removing those paths would be cleaner than overwriting with nonsense.
        substituteInPlace "$out"/lib/perl5/*/*/Config_heavy.pl \
          --replace "${libcInc}" /no-such-path \
          --replace "${
              if stdenv.cc.cc or null != null then stdenv.cc.cc else "/no-such-path"
            }" /no-such-path \
          --replace "$man" /no-such-path
      ''; # */

    meta = {
      homepage = https://arsv.github.io/perl-cross;
      description = "Cross-compilation standard implementation of the Perl 5 programmming language";
      maintainers = [ ];
      platforms = platforms.all;
    };
  };
in rec {
  perl = perl524;

  perl522 = common {
    perlVersion = "5.22.4";
    perlSha256 = "1yk1xn4wmnrf2ph02j28khqarpyr24qwysjzkjnjv7vh5dygb7ms";
  };

  perl524 = common {
    perlVersion = "5.24.3";
    perlSha256 = "1m2px85kq2fyp2d4rx3bw9kg3car67qfqwrs5vlv96dx0x8rl06b";
  };

  perl526 = common {
    perlVersion = "5.26.1";
    perlSha256 = "1p81wwvr5jb81m41d07kfywk5gvbk0axdrnvhc2aghcdbr4alqz7";
  };
}
