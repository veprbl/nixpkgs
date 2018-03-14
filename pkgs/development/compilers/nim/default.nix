{ stdenv, lib, fetchurl, makeWrapper
, boehmgc, coreutils, nodejs, openssl, pcre, readline, sfml, sqlite, tzdata }:

stdenv.mkDerivation rec {
  name = "nim-${version}";
  version = "0.18.0";

  src = fetchurl {
    url = "https://nim-lang.org/download/${name}.tar.xz";
    sha256 = "1l1vdygbgs5fdh2ffdjapcp90p8f6cbsw4hivndgm3gh6pdlmis5";
  };

  doCheck = true;

  enableParallelBuilding = true;

  NIX_LDFLAGS = [
    "-lcrypto"
    "-lpcre"
    "-lreadline"
    "-lsqlite3"
    "-lgc"
  ];

  hardeningDisable = [ "all" ];

  # 1. nodejs is only needed for tests
  # 2. we could create a separate derivation for the "written in c" version of nim
  #    used for bootstrapping, but koch insists on moving the nim compiler around
  #    as part of building it, so it cannot be read-only

  buildInputs  = [
    makeWrapper nodejs
    boehmgc openssl pcre readline sfml sqlite tzdata
  ];

  postPatch = ''
    # Fixup paths used in tests
    substituteInPlace tests/osproc/tworkingdir.nim --replace /usr/bin ${coreutils}/bin
    substituteInPlace tests/async/tioselectors.nim --replace /bin/sleep ${coreutils}/bin/sleep
    substituteInPlace tests/async/tupcoming_async.nim --replace /bin/sleep ${coreutils}/bin/sleep

    # Remove tests that need to fetch remote packages
    rm tests/manyloc/nake/nakefile.nim
    rm tests/manyloc/named_argument_bug/main.nim
    rm tests/manyloc/keineschweine/keineschweine.nim
    rm tests/cpp/tasync_cpp.nim
    rm tests/niminaction/Chapter7/Tweeter/src/tweeter.nim

    # Remove test that needs network
    rm tests/stdlib/thttpclient.nim
  '';

  buildPhase   = ''
    sh build.sh
    ./bin/nim c koch
    ./koch boot  -d:release \
                 -d:useGnuReadline \
                 ${lib.optionals (stdenv.isDarwin || stdenv.isLinux) "-d:nativeStacktrace"}
    ./koch tools -d:release
  '';

  installPhase = ''
    install -Dt $out/bin bin/* koch
    ./koch install $out
    mv $out/nim/bin/* $out/bin/ && rmdir $out/nim/bin
    mv $out/nim/*     $out/     && rmdir $out/nim
    wrapProgram $out/bin/nim \
      --suffix PATH : ${lib.makeBinPath [ stdenv.cc ]} \
      --set hardeningDisable all
  '';

  checkPhase = "./koch tests";

  meta = with stdenv.lib; {
    description = "Statically typed, imperative programming language";
    homepage = https://nim-lang.org/;
    license = licenses.mit;
    maintainers = with maintainers; [ ehmry peterhoeg ];
    platforms = with platforms; linux ++ darwin; # arbitrary
  };
}
