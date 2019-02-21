{stdenv, fetchFromGitHub
, buildPackages
, callPackage
, pkgconfig
, libusb, readline, libewf, perl, zlib, openssl
, libuv, libzip, xxHash
, gtk2 ? null, vte ? null, gtkdialog ? null
, python3 ? null
, ruby ? null
, lua ? null
, useX11 ? false
, rubyBindings ? false
, pythonBindings ? false
, luaBindings ? false
, file ? null
, useSysMagic ? false
}:

assert useX11 -> (gtk2 != null && vte != null && gtkdialog != null);
assert rubyBindings -> ruby != null;
assert pythonBindings -> python3 != null;


let
  inherit (stdenv.lib) optional;

  generic = {
    version_commit,
    gittap,
    gittip,
    rev,
    version,
    sha256,
    cs_ver,
    cs_sha256
  }:
    stdenv.mkDerivation rec {
      name = "radare2-${version}";

      src = fetchFromGitHub {
        owner = "radare";
        repo = "radare2";
        inherit rev sha256;
      };

      postPatch = let
        capstone = fetchFromGitHub {
          owner = "aquynh";
          repo = "capstone";
          # version from $sourceRoot/shlr/Makefile
          rev = cs_ver;
          sha256 = cs_sha256;
        };
      in ''
        mkdir -p build/shlr
        cp -r ${capstone} capstone-${cs_ver}
        chmod -R +w capstone-${cs_ver}
        # radare 3.3 compat for radare2-cutter
        (cd shlr && ln -s ../capstone-${cs_ver} capstone)
        tar -czvf shlr/capstone-${cs_ver}.tar.gz capstone-${cs_ver}
        # necessary because they broke the offline-build:
        # https://github.com/radare/radare2/commit/6290e4ff4cc167e1f2c28ab924e9b99783fb1b38#diff-a44d840c10f1f1feaf401917ae4ccd54R258
        # https://github.com/radare/radare2/issues/13087#issuecomment-465159716
        curl() { true; }
        export -f curl
      '';

      postInstall = ''
        install -D -m755 $src/binr/r2pm/r2pm $out/bin/r2pm
      '';

      WITHOUT_PULL="1";
      makeFlags = [
        "GITTAP=${gittap}"
        "GITTIP=${gittip}"
        "RANLIB=${stdenv.cc.bintools.bintools}/bin/${stdenv.cc.bintools.targetPrefix}ranlib"
      ];
      configureFlags = optional useSysMagic "--with-sysmagic"
      ++ [
        "--with-syszip"
        "--with-sysxxhash"
        "--with-openssl"
      ];

      enableParallelBuilding = true;
      depsBuildBuild = [ buildPackages.stdenv.cc ];

      nativeBuildInputs = [ pkgconfig ];
      buildInputs = [ readline libusb libewf perl libuv ]
        ++ optional useX11 [ gtkdialog vte gtk2 ]
        ++ optional rubyBindings [ ruby ]
        ++ optional pythonBindings [ python3 ]
        ++ optional luaBindings [ lua ];

      propagatedBuildInputs = [ zlib libzip xxHash openssl ]
        ++ optional useSysMagic [ file ];

      meta = {
        description = "unix-like reverse engineering framework and commandline tools";
        homepage = http://radare.org/;
        license = stdenv.lib.licenses.gpl2Plus;
        maintainers = with stdenv.lib.maintainers; [ raskin makefu mic92 ];
        platforms = with stdenv.lib.platforms; linux;
        inherit version;
      };
  };
in {
  #<generated>
  # DO NOT EDIT! Automatically generated by ./update.py
  radare2 = generic {
    version_commit = "20942";
    gittap = "3.3.0";
    gittip = "5a9127d2599c8ff61d8544be7d4c9384402e94a3";
    rev = "3.3.0";
    version = "3.3.0";
    sha256 = "11ap3icr8w0y49lq5dxch2h589qdmwf3qv9lsdyfsz4l0mjm49ri";
    cs_ver = "4.0.1";
    cs_sha256 = "0ijwxxk71nr9z91yxw20zfj4bbsbrgvixps5c7cpj163xlzlwba6";
  };
  r2-for-cutter = generic {
    version_commit = "20611";
    gittap = "3.2.1-123-gbbe5c2a31";
    gittip = "bbe5c2a31e984a93e465afbc4892352857e8aae9";
    rev = "bbe5c2a31e984a93e465afbc4892352857e8aae9";
    version = "2019-01-20";
    sha256 = "108cqpvq5pk348340jdpj74x1kxpakskhr4q9k2qn2vml8paywd2";
    cs_tip = "0ff8220adef16a942697afd245afc5ab0f70cbf8";
    cs_sha256 = "1ak8ysgivq28d23r77881p0z5v65jhpap5plm10p9j3y2x00n3zn";
  };
  #</generated>
}
