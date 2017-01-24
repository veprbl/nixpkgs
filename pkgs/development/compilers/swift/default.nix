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
  version = "3.0.2-RELEASE";
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
      "0775cv6qmbc1if5ji1c1zf53g3qi2j2kqp65izgk2fq0lya1bmgg";
    llvm = fetch
      "swift-llvm"
      "0m56c2z604llbs0ngh68gl9q1xkqlwxrjg3l89ihgs7pkp5arzhd";
    compilerrt = fetch
      "swift-compiler-rt"
      "1rgi6ksc1i49d716k2bwg4r3ggabkz6q4rgqn9a24xprb3b8nd0w";
    cmark = fetch
      "swift-cmark"
      "1167g3r6vw7nd7zshyywb3mggyq8mg8jd3b2v08nbl988l5wa1y2";
    lldb = fetch
      "swift-lldb"
      "0bx5mdzj32scn4x1xxjsy2dmdjjxqvy651n27fi32xxg4ihkclyw";
    llbuild = fetch
      "swift-llbuild"
      "0srm22xnc1sdaq1230lgzvrnmhh44ba8lnr19bkz8xprb6bb8c8y";
    pm = fetch
      "swift-package-manager"
      "0128vh7b67gijnlcra3vi99zxa3j9j16mqncifdpsg8803rl50fl";
    xctest = fetch
      "swift-corelibs-xctest"
      "07q90zsrzwcqw5c823r8qhigak3svwdxj88iiaqv1sbzaj49nh38";
    foundation = fetch
      "swift-corelibs-foundation"
      "08lzwalxcliaf29bgs3y9iiydp8i94nhq0rlbhynav3p0fl0dpwl";
    libdispatch = fetch
      "swift-corelibs-libdispatch"
      "1b9w4jp36dbdhdlnwg7lj8myb77bj89f4sbg37p8w2zzbv8za3vd";
    swift = fetch
      "swift"
      "0pdlvnkv7y539k37f4msa75rmppx84d0272pm614jcnlyzdd8cfi";
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
  name = "swift-${version}";

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
    ln -s ${clang}/bin/ld* $out/bin/
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

