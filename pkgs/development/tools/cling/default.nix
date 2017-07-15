{ stdenv, fetchzip, cmake, python, libffi }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "cling";
  version = "0.4";

  llvmRevision = "274612";

  clang = fetchzip {
    name = "clang-${llvmRevision}.tgz";
    url = "https://root.cern.ch/gitweb/?p=clang.git;a=snapshot;h=refs/tags/cling-patches-r${llvmRevision};sf=tgz";
    sha256 = "0iv8mb9d8j09smnr74k5yz2m06mx4n4cg7jxchn2f8y4yy1lhcgg";
  };

  cling = fetchzip {
    name = "cling-${version}.tgz";
    url = "https://root.cern.ch/gitweb/?p=cling.git;a=snapshot;h=refs/tags/v${version};sf=tgz";
    sha256 = "0rp5fniqnxqf2z9f5idnjwcakllrnhhbg4l5vcz72yq25xgi2k3z";
  };

  # cling is a build target in llvm
  src = fetchzip {
    name = "llvm-${llvmRevision}.tgz";
    url = "https://root.cern.ch/gitweb/?p=llvm.git;a=snapshot;h=refs/tags/cling-patches-r${llvmRevision};sf=tgz";
    sha256 = "0gwss7y7n0cg5vr4rl09dfk67680jvmpj1c5d41bm9dwqb4fha2c";
  };

  preConfigure = ''
    ln -s $clang tools/clang
    ln -s $cling tools/cling
  '';

  buildInputs = [ cmake python libffi ];

  cmakeFlags = [
    "-DLLVM_TARGETS_TO_BUILD=host"
    "-DLLVM_BUILD_LLVM_DYLIB=OFF"
    "-DLLVM_ENABLE_RTTI=ON"
    "-DLLVM_ENABLE_FFI=ON"
    "-DLLVM_BUILD_DOCS=OFF"
    "-DLLVM_ENABLE_SPHINX=OFF"
    "-DLLVM_ENABLE_DOXYGEN=OFF"
  ];

  buildPhase = ''
    runHook preBuild
    make -C tools/clang $makeFlags
    make -C tools/cling $makeFlags
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make -C tools/clang DESTDIR="$out" install
    make -C tools/cling DESTDIR="$out" install
    runHook postInstall
  '';

  meta = with stdenv.lib; {
    homepage = https://root.cern.ch/cling;
    description = "An interactive C++ interpreter, built on the top of LLVM and Clang libraries";
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.all;
  };
}
