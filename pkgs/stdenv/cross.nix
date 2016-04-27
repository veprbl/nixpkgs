{ lib, crossSystem
, binutils, glibc, uclibcCross, wrapGCCCross, gcc, file
, windows, darwin }:

/* LATER:
    - Rename `crossSystem` to just `cross`.
      It's messy to use multiple names for the same thing.
*/
rec {
  /* crossSystem: various configuration of cross-compiling
      .config: the "target triplet" in GNU style, i.e. CPU-vendor-OS
        https://www.gnu.org/software/autoconf/manual/autoconf-2.65/html_node/Specifying-Target-Triplets.html
      .namePrefix to be put in front of usual package names, empty by default
        We used *suffixing* by .config, i.e. after the version,
        but that didn't play well with the way versions are parsed.
  */

  # LATER
  forceNativeDrv = drv : if crossSystem == null then drv else
    (drv // { crossDrv = drv.nativeDrv; });

  getNativeDrv = lib.id; # LATER

  # Modify a stdenv so that its mkDerivation adds .nativeDrv and .crossDrv.
  # We do this even if crossConfig == null; then they are all the same.
  addDrvLinks = stdenv: stdenv // { mkDerivation = args:
    let
      nativeDrv = stdenv.mkDerivation args // links;
      crossDrv = getCrossDrv nativeDrv // links;
      links = { inherit nativeDrv crossDrv; };

      getCrossDrv = pkg: if crossSystem == null then pkg else
        assert ! pkg.outputUnspecified or false; # LATER: handle the other case - output selection
        pkg.override {
          stdenv = makeStdenvCross pkg.stdenv
            { inherit binutilsCross; ccCross = gccCrossStageFinal; };
        };
    in
      nativeDrv; # legacy: we use the non-cross derivation as the default
  };



  # Return a modified stdenv that is meant for cross-compilation.
  # Note that such stdenv will only be directly seen by a cross-compiled
  # package, not by a native one (even if crossSystem is configured).
  makeStdenvCross = stdenv: { binutilsCross, ccCross }: stdenv //
    {
      inherit ccCross binutilsCross;
      gccCross = ccCross;
      cross = crossSystem;

      mkDerivation =
        { name ? "", buildInputs ? [], nativeBuildInputs ? [],
          propagatedBuildInputs ? [], propagatedNativeBuildInputs ? [],
          selfNativeBuildInput ? false, ...
        }@args:
        let
          # LATER: perhaps inline or shorten the names
          getCrossDrv = p: p.crossDrv;
          getNativeDrv = p: p.nativeDrv;

          # In nixpkgs, sometimes 'null' gets in as a buildInputs element,
          # and we handle that through isAttrs.
          # LATER: perhaps inline some of these maps
          nativeBuildInputsDrvs = map getNativeDrv nativeBuildInputs;
          buildInputsDrvs = map getCrossDrv buildInputs;
          buildInputsDrvsAsBuildInputs = map getNativeDrv buildInputs;
          propagatedBuildInputsDrvs = map getCrossDrv propagatedBuildInputs;
          propagatedNativeBuildInputsDrvs = map getNativeDrv propagatedNativeBuildInputs;

          # The base stdenv already knows that nativeBuildInputs and
          # buildInputs should be built with the usual gcc-wrapper
          # And the same for propagatedBuildInputs.
          nativeDrv = stdenv.mkDerivation args;

          # Temporary expression until the cross_renaming, to handle the
          # case of pkgconfig given as buildInput, but to be used as
          # nativeBuildInput. # LATER: do something about this madness
          hostAsNativeDrv = drv:
              builtins.unsafeDiscardStringContext drv.nativeDrv.drvPath
              == builtins.unsafeDiscardStringContext drv.crossDrv.drvPath;
          buildInputsNotNull = stdenv.lib.filter
              (drv: builtins.isAttrs drv && drv ? nativeDrv) buildInputs;
          nativeInputsFromBuildInputs = stdenv.lib.filter hostAsNativeDrv buildInputsNotNull;

          # We should overwrite the input attributes in crossDrv, to overwrite
          # the defaults for only-native builds in the base stdenv
          crossDrv = if crossSystem == null then nativeDrv else
              stdenv.mkDerivation (args // {
                  name = crossSystem.namePrefix or ""  + name;
                  nativeBuildInputs = nativeBuildInputsDrvs
                    ++ nativeInputsFromBuildInputs
                    ++ [ ccCross binutilsCross ]
                    ++ stdenv.lib.optional selfNativeBuildInput nativeDrv
                      # without proper `file` command, libtool sometimes fails
                      # to recognize 64-bit DLLs
                    ++ stdenv.lib.optional
                        (crossSystem.config  == "x86_64-w64-mingw32")
                        (getNativeDrv file)
                    ;

                  # Cross-linking dynamic libraries, every buildInput should
                  # be propagated because ld needs the -rpath-link to find
                  # any library needed to link the program dynamically at
                  # loader time. ld(1) explains it.  # LATER: review this
                  buildInputs = [];
                  propagatedBuildInputs = propagatedBuildInputsDrvs ++ buildInputsDrvs;
                  propagatedNativeBuildInputs = propagatedNativeBuildInputsDrvs;

                  crossConfig = crossSystem.config;
              } // args.crossAttrs or {});
        in # mkDerivation body
          nativeDrv // {
        inherit crossDrv nativeDrv;
      };
    };




  # LATER: assert on crossSystem when evaluating anything below


  binutilsCross = lib.lowPrio (forceNativeDrv (
    if crossSystem.libc == "libSystem" then darwin.cctools_cross
    else binutils.override {
      noSysDirs = true;
      cross = crossSystem;
    }
  ));

  glibcCross = forceNativeDrv (glibc.override {
    gccCross = gccCrossStageStatic;
  });

  libcCross =
    { # switch
      "glibc" = glibcCross;
      "uclibc" = uclibcCross;
      "msvcrt" = windows.mingw_w64;
      "libSystem" = darwin.xcode;
    }.${crossSystem.libc} or throw "Unknown libc '${crossSystem.libc}'";


  gccCrossStageStatic = let
    libcCross1 =
      if crossSystem.libc == "msvcrt" then windows.mingw_w64_headers
      else if crossSystem.libc == "libSystem" then darwin.xcode
      else null;
    in wrapGCCCross {
      gcc = forceNativeDrv (gcc.cc.override {
        cross = crossSystem;
        crossStageStatic = true;
        langCC = false;
        libcCross = libcCross1;
        enableShared = false;
      });
      libc = libcCross1;
      binutils = binutilsCross;
      cross = crossSystem;
  };

  # Only needed for mingw builds
  gccCrossMingw2 = wrapGCCCross {
    gcc = gccCrossStageStatic.gcc;
    libc = windows.mingw_headers2;
    binutils = binutilsCross;
    cross = crossSystem;
  };

  gccCrossStageFinal = wrapGCCCross {
    gcc = forceNativeDrv (gcc.cc.override {
      cross = crossSystem;
      crossStageStatic = false;
    });
    libc = libcCross;
    binutils = binutilsCross;
    cross = crossSystem;
  };

}
