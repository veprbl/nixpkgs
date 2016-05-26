{ stdenv, lib, fetchurl, zlib, xz, python, findXMLCatalogs, libiconv
, autoreconfHook, gnum4, pkgconfig, fetchFromGitHub
, supportPython ? (! stdenv ? cross) }:

let
  repoPath = "/home/admin/nix/tmp/libxml2";
  self =
stdenv.mkDerivation rec {
  name = "libxml2-${version}";
  /*
  version = "2.9.3";

  src = fetchurl {
    url = "http://xmlsoft.org/sources/${name}.tar.gz";
    sha256 = "0bd17g6znn2r98gzpjppsqjg33iraky4px923j3k8kdl8qgy7sad";
  };
  */

  src = lib.cleanSource repoPath;
  version = with lib; substring 0 7 (commitIdFromGitRepo "${repoPath}/.git");
  nativeBuildInputs = [ autoreconfHook gnum4 pkgconfig ];


  outputs = [ "dev" "out" "bin" "doc" ]
    ++ lib.optional supportPython "py";
  propagatedBuildOutputs = "out bin" + lib.optionalString supportPython " py";

  buildInputs = lib.optional supportPython python
    # Libxml2 has an optional dependency on liblzma.  However, on impure
    # platforms, it may end up using that from /usr/lib, and thus lack a
    # RUNPATH for that, leading to undefined references for its users.
    ++ lib.optional stdenv.isFreeBSD xz;

  propagatedBuildInputs = [ zlib findXMLCatalogs ];

  configureFlags = lib.optional supportPython "--with-python=${python}"
    ++ [ "--exec_prefix=$dev" ];

  enableParallelBuilding = true;

  crossAttrs = lib.optionalAttrs (stdenv.cross.libc == "msvcrt") {
    # creating the DLL is broken ATM
    dontDisableStatic = true;
    configureFlags = configureFlags ++ [ "--disable-shared" ];

    # libiconv is a header dependency - propagating is enough
    propagatedBuildInputs =  [ findXMLCatalogs libiconv ];
  };

  preInstall = lib.optionalString supportPython
    ''substituteInPlace python/libxml2mod.la --replace "${python}" "$py"'';
  installFlags = lib.optionalString supportPython
    ''pythondir="$(py)/lib/${python.libPrefix}/site-packages"'';

  postFixup = ''
    moveToOutput bin/xml2-config "$dev"
    moveToOutput lib/xml2Conf.sh "$dev"
    moveToOutput share/man/man1 "$bin"
  '';

  passthru = { inherit version; pythonSupport = supportPython;

    test = stdenv.mkDerivation {
      name = self.version + "-test";
      src = fetchFromGitHub {
        owner = "shlomif";
        repo = "libxml2-2.9.4-reader-schema-regression";
        rev = "1f5518d";
        sha256 = "0ccysxxbnqj8vqxaasszksi2xb2c0l1ccr07lwlmhxvcdxx232wf";
      };
      buildInputs = [ self ];
      # the difference here is that with 2.9.4 the test prints stuff to stderr
      buildCommand = ''
        mkdir -p "$out/bin" # to succeed
        cd "$src"
        gcc reader.c -I${self.dev}/include/libxml2 -lxml2 -o "$out/bin/test"
        result="$("$out/bin/test" 2>&1 | head -n 1)" || true
        echo "$result"
        [ "$result" == "ret=1" ]
      '';
    };

  };

  meta = {
    homepage = http://xmlsoft.org/;
    description = "An XML parsing library for C";
    license = "bsd";
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.eelco ];
  };
};
in self
