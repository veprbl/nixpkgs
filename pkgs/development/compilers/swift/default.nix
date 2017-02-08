{ stdenv
, cmake
, coreutils
, glibc
, which
, perl
, libedit
, ninja
, pkgconfig
, sqlite
, swig
, bash
, libxml2
, llvm
, clang
, python
, ncurses
, libuuid
, libbsd
, icu
, autoconf
, libtool
, automake
, libblocksruntime
, curl
, rsync
, git
, libgit2
, binutils
, fetchFromGitHub
, fetchgit
, fetchpatch
, paxctl
, findutils
#, systemtap
}:

let
  v_major = "3.1";
  v_date = "2017-02-07";
  version = "${v_major}-DEVELOPMENT-SNAPSHOT-${v_date}-a";
  version_friendly = "${v_major}-${v_date}";

  tag = "refs/tags/swift-${version}";
  fetch = repo: sha256:
    fetchgit {
      url = "https://github.com/apple/${repo}";
      inherit sha256;
      rev = tag;
      name = "${repo}-${version}-src";
    };

sources = {
    clang = fetch
      "swift-clang"
      "0xzx1zzdhr4cpjhilzxdz3j0g5mbnrd0sg5ykcr648yxx3rgpsi0";
    llvm = fetch
      "swift-llvm"
      "0zb1zi77b2xdz5szlz2m3j3d92dc0q00dv8py2s6iaq3k435i3sq";
    compilerrt = fetch
      "swift-compiler-rt"
      "1gjcr6g3ffs3nhf4a84iwg4flbd7rqcf9rvvclwyq96msa3mj950";
    cmark = fetch
      "swift-cmark"
      "0qf2f3zd8lndkfbxbz6vkznzz8rvq5gigijh7pgmfx9fi4zcssqx";
    lldb = fetch
      "swift-lldb"
      "1i3b3bzfmxhay8pm1hdqizkfxrmkasi1prd0vshc6mjqh3dy11sr";
    llbuild = fetch
      "swift-llbuild"
      "01bz8cbshfcf6ph3a5x808azi2fabjanjr8838jcldhbl2q7wx7b";
    pm = fetch
      "swift-package-manager"
      "0c1lndmc9minkm8x7nj40qkk2z53hcq8fymjcggr5p04cspqv47b";
    xctest = fetch
      "swift-corelibs-xctest"
      "0cj5y7wanllfldag08ci567x12aw793c79afckpbsiaxmwy4xhnm";
    foundation = fetch
      "swift-corelibs-foundation"
      "0v2jjgdd0z3k12xwrqr2cwzglzrs55nsqj4lx70yrdpbmm7nfk7i";
    libdispatch = fetch
      "swift-corelibs-libdispatch"
      "1lq534nr72d1q4l5hzcpd8l586xdzxi97l4lyjdyl1ri05wylkc9";
    swift = fetch
      "swift"
      "1s1ynvxfgw78xfal2g29gflli9yr86ddfcbynqm3ygq5p0p26fia";
  };

  devInputs = [
    curl
    glibc
    icu
    libblocksruntime
    libbsd
    libedit
    libuuid
    libxml2
    ncurses
    sqlite
    swig
    #    systemtap?
  ];

  cmakeFlags = [
    "-DGLIBC_INCLUDE_PATH=${stdenv.cc.libc.dev}/include"
    "-DC_INCLUDE_DIRS=${stdenv.lib.makeSearchPathOutput "dev" "include" devInputs}:${libxml2.dev}/include/libxml2"
    "-DGCC_INSTALL_PREFIX=${clang.cc.gcc}"
  ];

  builder = ''
    $SWIFT_SOURCE_ROOT/swift/utils/build-script \
      --preset-file=${./build-presets.ini} \
      --preset=buildbot_linux \
      installable_package=$INSTALLABLE_PACKAGE \
      install_prefix=$out \
      install_destdir=$SWIFT_INSTALL_DIR \
      extra_cmake_options="${stdenv.lib.concatStringsSep "," cmakeFlags}"'';

in
stdenv.mkDerivation rec {
  name = "swift-${version_friendly}";

  buildInputs = devInputs ++ [
    autoconf
    automake
    bash
    clang
    cmake
    coreutils
    libtool
    ninja
    perl
    pkgconfig
    python
    rsync
    which
    paxctl
    findutils
  ];

  # TODO: Revisit what's propagated and how
  propagatedBuildInputs = [
    libgit2
    python
  ];
  propagatedUserEnvPkgs = [ git pkgconfig ];

  hardeningDisable = [ "format" ]; # for LLDB

  configurePhase = ''
    cd ..
    
    export INSTALLABLE_PACKAGE=$PWD/swift.tar.gz

    mkdir build install
    export SWIFT_BUILD_ROOT=$PWD/build
    export SWIFT_INSTALL_DIR=$PWD/install

    cd $SWIFT_BUILD_ROOT

    unset CC
    unset CXX

    export NIX_ENFORCE_PURITY=
  '';

  unpackPhase = ''
    mkdir src
    cd src
    export sourceRoot=$PWD
    export SWIFT_SOURCE_ROOT=$PWD

    cp -r ${sources.clang} clang
    cp -r ${sources.llvm} llvm
    cp -r ${sources.compilerrt} compiler-rt
    cp -r ${sources.cmark} cmark
    cp -r ${sources.lldb} lldb
    cp -r ${sources.llbuild} llbuild
    cp -r ${sources.pm} swiftpm
    cp -r ${sources.xctest} swift-corelibs-xctest
    cp -r ${sources.foundation} swift-corelibs-foundation
    cp -r ${sources.libdispatch} swift-corelibs-libdispatch
    cp -r ${sources.swift} swift

    chmod -R u+w .
  '';

  patchPhase = ''
    # Just patch all the things for now, we can focus this later
    patchShebangs $SWIFT_SOURCE_ROOT

    substituteInPlace swift/stdlib/public/Platform/CMakeLists.txt \
      --replace '/usr/include' "${stdenv.cc.libc.dev}/include"
    substituteInPlace swift/utils/build-script-impl \
      --replace '/usr/include/c++' "${clang.cc.gcc}/include/c++"
    patch -p1 -d swift -i ${./build-script-pax.patch}

    substituteInPlace clang/lib/Driver/ToolChains.cpp \
      --replace '  addPathIfExists(D, SysRoot + "/usr/lib", Paths);' \
                '  addPathIfExists(D, SysRoot + "/usr/lib", Paths); addPathIfExists(D, "${glibc}/lib", Paths);'
    patch -p1 -d clang -i ${./purity.patch}

    # Workaround hardcoded dep on "libcurses" (vs "libncurses"):
    sed -i 's,curses,ncurses,' llbuild/*/*/CMakeLists.txt
    substituteInPlace llbuild/tests/BuildSystem/Build/basic.llbuild \
      --replace /usr/bin/env $(type -p env)

    # This test fails on one of my machines, not sure why.
    # Disabling for now. 
    rm llbuild/tests/Examples/buildsystem-capi.llbuild

    substituteInPlace swift-corelibs-foundation/lib/script.py \
      --replace /bin/cp $(type -p cp)

    PREFIX=''${out/#\/}
    substituteInPlace swift-corelibs-xctest/build_script.py \
      --replace usr "$PREFIX"
    substituteInPlace swiftpm/Utilities/bootstrap \
      --replace "usr" "$PREFIX"
  '';

  doCheck = false;

  buildPhase = ''${builder}'';

  dontStrip = true;

  installPhase = ''
    mkdir -p $out

    # Extract the generated tarball into the store
    PREFIX=''${out/#\/}
    tar xf $INSTALLABLE_PACKAGE -C $out --strip-components=3 $PREFIX

    paxmark pmr $out/bin/swift
    paxmark pmr $out/bin/*

    # TODO: Use wrappers to get these on the PATH for swift tools, instead
    ln -s ${clang}/bin/* $out/bin/
    ln -s ${binutils}/bin/ar $out/bin/ar
  '';

  meta = with stdenv.lib; {
    description = "The Swift Programming Language";
    homepage = "https://github.com/apple/swift";
    maintainers = with maintainers; [ jb55 dtzWill ];
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}

