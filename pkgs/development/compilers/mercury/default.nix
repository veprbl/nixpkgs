{ stdenv, fetchurl, fetchFromGitHub, gcc, flex, bison, texinfo, makeWrapper ,
readline, jdk, erlang }:


let
  mkMercury = stdenv.lib.makeOverridable mkMercury';
  mkMercury' = args @ { src, version, enableMinimal ? false, compilers ? [ gcc ], bootstrapMercury ? null, ... }:
    stdenv.mkDerivation (args // rec {
      name    = "mercury-${if enableMinimal then "minimal-" else ""}${version}";
      inherit src version;

      buildInputs = compilers ++ [ bootstrapMercury flex bison texinfo makeWrapper readline ];

      patchPhase = ''
        # Fix calls to programs in /bin
        for p in uname pwd ; do
          for f in $(egrep -lr /bin/$p *) ; do
            sed -i 's@/bin/'$p'@'$p'@g' $f ;
          done
        done
      '';

      preConfigure = ''
        mkdir -p $out/lib/mercury/cgi-bin
      '';

      configureFlags = [
        (
          if enableMinimal
          then "--enable-minimal-install"
          else "--enable-deep-profiler=${placeholder "out"}/lib/mercury/cgi-bin"
        )
      ];

      preBuild = ''
        # Mercury buildsystem does not take -jN directly.
        makeFlags="PARALLEL=-j$NIX_BUILD_CORES" ;
      '';

      postInstall = ''
        # Wrap with compilers for the different targets.
        for e in $(ls $out/bin) ; do
          wrapProgram $out/bin/$e \
            --prefix PATH ":" "${stdenv.lib.makeBinPath compilers}"
        done
      '';

      meta = {
        description = "A pure logic programming language";
        longDescription = ''
          Mercury is a logic/functional programming language which combines the
          clarity and expressiveness of declarative programming with advanced
          static analysis and error detection features.  Its highly optimized
          execution algorithm delivers efficiency far in excess of existing logic
          programming systems, and close to conventional programming systems.
          Mercury addresses the problems of large-scale program development,
          allowing modularity, separate compilation, and numerous optimization/time
          trade-offs.
        '';
        homepage    = "http://mercurylang.org";
        license     = stdenv.lib.licenses.gpl2;
        platforms = stdenv.lib.platforms.linux;
        maintainers = [ ];
      };
    });

in rec {
  mercury_14 = mkMercury rec {
    version = "14.01.1";
    src = fetchurl {
      url    = "https://dl.mercurylang.org/release/mercury-srcdist-${version}.tar.gz";
      sha256 = "12z8qi3da8q50mcsjsy5bnr4ia6ny5lkxvzy01a3c9blgbgcpxwq";
    };
  };
  mercury_14_bootstrap = mercury_14.override { enableMinimal = true; };
  mercury_14_full = mercury_14.override { compilers = [ gcc erlang jdk ]; };
  mercury-git = mkMercury {
    version = "2018-10-19";
    src = fetchFromGitHub {
      owner = "Mercury-Language";
      repo = "mercury";
      rev = "3cf72e496ab4d28ceb18c0564f5ba31d3d72c89a";
      sha256 = "1x6k7siq9qh1fm87ddg0c0nmk59aw62m5v7fza2bkkshyp7d7qs8";
    };
    bootstrapMercury = mercury_14_bootstrap;
  };
}
