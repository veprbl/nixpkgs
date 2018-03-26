/* This file defines the composition for Lua packages.  It has
  been factored out of all-packages.nix because there are many of
   them.  Also, because most Nix expressions for Lua packages are
   trivial, most are actually defined here.  I.e. there's no function
   for each package in a separate file: the call to the function would
   be almost as must code as the function itself. */
{ fetchurl, fetchzip, stdenv, lua, callPackage, unzip, zziplib, pkgconfig, libtool
, libiconv
, pcre, oniguruma, gnulib, tre, glibc, sqlite, openssl, expat, cairo
, perl, gtk2, python, glib, gobjectIntrospection, libevent, zlib, autoreconfHook
, mysql, postgresql, cyrus_sasl
, fetchFromGitHub, libmpack, which, fetchpatch, writeText
, pkgs
, recurseIntoAttrs
, fetchgit
, overrides ? (self: super: {})
, lib
}:

let
  packages = ( self:

let
  luaAtLeast = lib.versionAtLeast lua.majorVersion;
  luaOlder = lib.versionOlder lua.majorVersion;
  isLua51 = (lib.versions.majorMinor lua.version) == "5.1";
  isLua52 = (lib.versions.majorMinor lua.version) == "5.2";
  isLuaJIT = (builtins.parseDrvName lua.name).name == "luajit";

  # Check whether a derivation provides a lua module.
  hasLuaModule = drv: drv? luaModule ;

  callPackage = pkgs.newScope self;

  requiredLuaModules = drvs: with stdenv.lib; let
    modules =  filter hasLuaModule drvs;
  in unique ([lua] ++ modules ++ concatLists (catAttrs "requiredLuaModules" modules));

  # Convert derivation to a lua module.
  toLuaModule = drv:
    drv.overrideAttrs( oldAttrs: {
      # Use passthru in order to prevent rebuilds when possible.
      passthru = (oldAttrs.passthru or {})// {
        luaModule = lua;
        requiredLuaModules = requiredLuaModules drv.propagatedBuildInputs;
      };
    });


  platformString =
    if stdenv.isDarwin then "macosx"
    else if stdenv.isFreeBSD then "freebsd"
    else if stdenv.isLinux then "linux"
    else if stdenv.isSunOS then "solaris"
    else throw "unsupported platform";

  #define build lua package function
  # makeOverridableLuaPackage
  buildLuaPackage = with pkgs.lib; makeOverridable( callPackage ../development/interpreters/lua-5/build-lua-package.nix {
    # inherit wrapLua;
    inherit toLuaModule;
    inherit lua writeText;
  });

  buildLuaApplication = args: buildLuaPackage ({namePrefix="";} // args );

  path=./lua-generated-packages.nix;
    # when updating the generated packages goes wrong, remove the file
    # generatedPackages = let path=./lua-generated-packages.nix; in
    # if (builtins.pathExists path) then callPackage path {
    #   # inherit self stdenv fetchurl requiredLuaModules luaOlder luaAtLeast
    #   # isLua51 isLua52;
    # } else {};
    generatedPackages = lib.optionalAttrs (builtins.pathExists path) (import path {
      inherit self stdenv fetchurl requiredLuaModules luaOlder luaAtLeast
      isLua51 isLua52 isLuaJIT buildLuaPackage lua;
    } );

  /* list of packages
   *
   */
   # _self = with self; {
in
# (generatedPackages // {
  # hum doesn't need self ? can do with lua.pkgs ?
  (generatedPackages // rec {

    inherit toLuaModule;
    inherit requiredLuaModules luaOlder luaAtLeast
      isLua51 isLua52 isLuaJIT buildLuaPackage lua;
    # inherit (stdenv.lib) maintainers;

  wrapLua = callPackage ../development/interpreters/lua-5/wrap-lua.nix {
    inherit lua; inherit (pkgs) makeSetupHook makeWrapper;
  };


  luarocks-upstream = callPackage ../development/tools/misc/luarocks {
    inherit lua;
    inherit toLuaModule;
  };
  luarocks = luarocks-upstream;
  luarocks-nix = luarocks-upstream.overrideAttrs(old: {
    src = fetchFromGitHub {
      owner="teto";
      repo="luarocks";
      rev="be2c1542f78fd7bb686b4c7338b1ccd7c3c3cf9c";
      sha256 = "00x6d0dahwgzqlvsf013qbxm3xr89vbdw547p9hkraz5y7y9l9ci";
    };
  });


  ##########################################3
  #### fixes for generated packages
  ##########################################3
  # TODO include this only when generatedPackages exist
  ltermbox = generatedPackages.ltermbox.override( {
    disabled = !isLua51 || isLuaJIT;
  });

  luazip = generatedPackages.luazip.overrideAttrs(old: {
    buildInputs = old.buildInputs ++ [ zziplib ];
  });

  lua-cmsgpack = generatedPackages.lua-cmsgpack.override({
    # TODO this should work with luajit once we fix luajit headers ?
    # TODO won't work, the disabled needs to be be on the override
    disabled = (!isLua51) || isLuaJIT;
  });

  luazlib=lua-zlib;
  lua-zlib = generatedPackages.lua-zlib.override({
    buildInputs = [ zlib.dev ];
    disabled=luaOlder "5.1" || luaAtLeast "5.4";
  });

  lua-iconv = generatedPackages.lua-iconv.override({
    buildInputs = [ libiconv ];
    disabled=!isLua51;
  });
  luaexpat = generatedPackages.luaexpat.override({
    buildInputs = [ expat.dev ];
    disabled=isLuaJIT;
  });
  luaevent = generatedPackages.luaevent.override({
    buildInputs = [ libevent.dev libevent ];
    extraConfig=''
      variables={
        EVENT_INCDIR="${libevent.dev}/include";
        EVENT_LIBDIR="${libevent}/lib";
      }
      '';
    disabled= luaOlder "5.1" || luaAtLeast "5.4" || isLuaJIT;
  });
  lrexlib-posix = generatedPackages.lrexlib-posix.override({
    buildInputs = [ glibc.dev ];
  });
  lrexlib-gnu = generatedPackages.lrexlib-gnu.override({
    buildInputs = [ gnulib ];
  });
  lua-cjson = generatedPackages.lua-cjson.override({
    disabled=isLuaJIT;
  });
  cjson = lua-cjson;
  luadbi = generatedPackages.luadbi.override({
    buildInputs = [ mysql.connector-c postgresql sqlite ];
  });
  luasec = generatedPackages.luasec.override({
    extraConfig=''
      variables={
        OPENSSL_INCDIR="${openssl.dev}/include";
        OPENSSL_LIBDIR="${openssl.out}/lib";
      }
      '';
  });

  luabitop = buildLuaPackage rec {
    version = "1.0.2";
    pname = "bitop";

    src = fetchurl {
      url = "https://luarocks.org/manifests/luarocks/luabitop-1.0.2-1.src.rock";
      sha256 = "0vpji9a7ab6g3k30hqc4pz8yr51zn455pyfppq9ywqkllmjq0ypw";
    };

    disabled = luaAtLeast "5.3";
    buildFlags = lib.optionalString stdenv.isDarwin "macosx";

    postPatch = lib.optionalString stdenv.isDarwin ''
      substituteInPlace Makefile --replace 10.4 10.5
    '';

    meta = with stdenv.lib; {
      description = "C extension module for Lua which adds bitwise operations on numbers";
      homepage = "http://bitop.luajit.org";
      license = licenses.mit;
      maintainers = with maintainers; [ ];
    };
  };

  luacyrussasl = toLuaModule(stdenv.mkDerivation( rec {
    version = "1.1.0";
    name = "lua-cyrussasl-${version}";
    src = fetchFromGitHub {
      owner = "JorjBauer";
      repo = "lua-cyrussasl";
      rev = "v${version}";
      sha256 = "14kzm3vk96k2i1m9f5zvpvq4pnzaf7s91h5g4h4x2bq1mynzw2s1";
    };

    preBuild = ''
      makeFlagsArray=(
        CFLAGS="-O2 -fPIC"
        LDFLAGS="-O -shared -fpic -lsasl2"
        LUAPATH="$out/share/lua/${lua.majorVersion}"
        CPATH="$out/lib/lua/${lua.majorVersion}"
      );
      mkdir -p $out/{share,lib}/lua/${lua.majorVersion}
    '';

    buildInputs = [ lua cyrus_sasl ];

    meta = with stdenv.lib; {
      homepage = https://github.com/JorjBauer/lua-cyrussasl;
      description = "Cyrus SASL library for Lua 5.1+";
      license = licenses.bsd3;
    };
  }));

  # lua 5.1 only ?
  bit32 = buildLuaPackage rec {
    pname = "bit32";
    version = "5.3.0-1";

    src = fetchurl {
      url    = https://luarocks.org/bit32-5.3.0-1.src.rock;
      sha256 = "19i7kc2pfg9hc6qjq4kka43q6qk71bkl2rzvrjaks6283q6wfyzy";
    };

    propagatedBuildInputs = [ lua ];

    buildType="builtin";

    meta = {
      homepage = "http://www.lua.org/manual/5.2/manual.html#6.7";
      description="Lua 5.2 bit manipulation library";
      license = {
        fullName = "MIT/X11";
      };
    };
  };

  luxio = toLuaModule(stdenv.mkDerivation( rec {
    name = "luxio-${version}";
    version = "13";

    src = fetchurl {
      url = "https://git.gitano.org.uk/luxio.git/snapshot/luxio-luxio-13.tar.bz2";
      sha256 = "1hvwslc25q7k82rxk461zr1a2041nxg7sn3sw3w0y5jxf0giz2pz";
    };

    nativeBuildInputs = [ which pkgconfig ];

    postPatch = ''
      patchShebangs .
    '';

    preBuild = ''
      makeFlagsArray=(
        INST_LIBDIR="$out/lib/lua/${lua.majorVersion}"
        INST_LUADIR="$out/share/lua/${lua.majorVersion}"
        LUA_BINDIR="$out/bin"
        INSTALL=install
        );
    '';

    meta = with stdenv.lib; {
      description = "Lightweight UNIX I/O and POSIX binding for Lua";
      homepage = https://www.gitano.org.uk/luxio/;
      license = licenses.mit;
      maintainers = with maintainers; [ richardipsum ];
      platforms = platforms.unix;
    };
  }));

  luastdlib = toLuaModule(stdenv.mkDerivation( rec {
    name = "stdlib-${version}";
    version = "41.2.1";

    src = fetchFromGitHub {
      owner = "lua-stdlib";
      repo = "lua-stdlib";
      rev = "release-v${version}";
      sha256 = "03wd1qvkrj50fjszb2apzdkc8d5bpfbbi9pajl0vbrlzzmmi3jlq";
    };

    nativeBuildInputs = [ autoreconfHook unzip ];
    buildInputs = [ lua ];

    meta = with stdenv.lib; {
      description = "General Lua libraries";
      homepage = "https://github.com/lua-stdlib/lua-stdlib";
      license = licenses.mit;
      maintainers = with maintainers; [ vyp ];
      platforms = platforms.linux;
    };
  }));

  lrexlib = toLuaModule( stdenv.mkDerivation(rec {
    name = "lrexlib-${version}";
    version = "2.8.0";

    src = fetchFromGitHub {
      owner = "rrthomas";
      repo = "lrexlib";
      rev = "rel-2-8-0";
      sha256 = "1c62ny41b1ih6iddw5qn81gr6dqwfffzdp7q6m8x09zzcdz78zhr";
    };

    external_deps = buildInputs;
    buildInputs = [ lua luastdlib pcre luarocks oniguruma gnulib tre glibc ];

    # because of luarocks's new cmake dependency
    dontUseCmakeConfigure = true;

    buildPhase = let
      luaVariable = ''LUA_PATH="${luastdlib}/share/lua/${lua.majorVersion}/?/init.lua;${luastdlib}/share/lua/${lua.majorVersion}/?.lua"'';
      pcreVariable = "PCRE_DIR=${pcre.out} PCRE_INCDIR=${pcre.dev}/include";
      onigVariable = "ONIG_DIR=${oniguruma}";
      gnuVariable = "GNU_INCDIR=${gnulib}/lib";
      treVariable = "TRE_DIR=${tre}";
      posixVariable = "POSIX_DIR=${glibc.dev}";
    in ''
      sed -e 's@$(LUAROCKS) $(LUAROCKS_COMMAND) $$i;@$(LUAROCKS) $(LUAROCKS_COMMAND) $$i ${pcreVariable} ${onigVariable} ${gnuVariable} ${treVariable} ${posixVariable};@' -i Makefile
      ${luaVariable} make
    '';

    installPhase = ''
      mkdir -pv $out;
      cp -r luarocks/lib $out;
    '';

    meta = with stdenv.lib; {
      description = "Lua bindings of various regex library APIs";
      homepage = "https://github.com/rrthomas/lrexlib";
      license = licenses.mit;
      maintainers = with maintainers; [ vyp ];
      platforms = platforms.linux;
    };
  }));

  # TODO won't work with lua5.3
  luasqlite3 = if luaAtLeast "5.3" then null else toLuaModule(stdenv.mkDerivation( rec {
    name = "sqlite3-${version}";
    version = "2.3.0";

    src = fetchFromGitHub {
      owner = "LuaDist";
      repo = "luasql-sqlite3";
      rev = version;
      sha256 = "05k8zs8nsdmlwja3hdhckwknf7ww5cvbp3sxhk2xd1i3ij6aa10b";
    };

    buildInputs = [ lua sqlite ];

    # disabled = !isLua51 luaAtLeast "5.2";
    makeFlags = [ "PREFIX=$out" ];
    patches = [ ../development/lua-modules/luasql.patch ];

    meta = with stdenv.lib; {
      description = "Database connectivity for Lua";
      homepage = "https://github.com/LuaDist/luasql-sqlite3";
      license = licenses.mit;
      maintainers = with maintainers; [ vyp ];
      platforms = platforms.linux;
    };
  }));

  lgi = toLuaModule(stdenv.mkDerivation( rec {
    name = "lgi-${version}";
    version = "0.9.2";

    src = fetchFromGitHub {
      owner = "pavouk";
      repo = "lgi";
      rev = version;
      sha256 = "03rbydnj411xpjvwsyvhwy4plm96481d7jax544mvk7apd8sd5jj";
    };

    nativeBuildInputs = [ pkgconfig ];
    buildInputs = [ glib gobjectIntrospection lua ];

    makeFlags = [ "LUA_VERSION=${lua.majorVersion}" ];

    preBuild = ''
      sed -i "s|/usr/local|$out|" lgi/Makefile
    '';

    patches = [
      (fetchpatch {
        name = "lgi-find-cairo-through-typelib.patch";
        url = "https://github.com/psychon/lgi/commit/46a163d9925e7877faf8a4f73996a20d7cf9202a.patch";
        sha256 = "0gfvvbri9kyzhvq3bvdbj2l6mwvlz040dk4mrd5m9gz79f7w109c";
      })
    ];

    meta = with stdenv.lib; {
      description = "GObject-introspection based dynamic Lua binding to GObject based libraries";
      homepage    = https://github.com/pavouk/lgi;
      license     = licenses.mit;
      maintainers = with maintainers; [ lovek323 rasendubi ];
      platforms   = platforms.unix;
    };
  }));
  vicious = toLuaModule(stdenv.mkDerivation( rec {
    name = "vicious-${version}";
    version = "2.3.1";

    src = fetchFromGitHub {
      owner = "Mic92";
      repo = "vicious";
      rev = "v${version}";
      sha256 = "1yzhjn8rsvjjsfycdc993ms6jy2j5jh7x3r2ax6g02z5n0anvnbx";
    };

    buildInputs = [ lua ];

    installPhase = ''
      mkdir -p $out/lib/lua/${lua.majorVersion}/
      cp -r . $out/lib/lua/${lua.majorVersion}/vicious/
      printf "package.path = '$out/lib/lua/${lua.majorVersion}/?/init.lua;' ..  package.path\nreturn require((...) .. '.init')\n" > $out/lib/lua/${lua.majorVersion}/vicious.lua
    '';

    meta = with stdenv.lib; {
      description = "A modular widget library for the awesome window manager";
      homepage    = https://github.com/Mic92/vicious;
      license     = licenses.gpl2;
      maintainers = with maintainers; [ makefu mic92 ];
      platforms   = platforms.linux;
    };
  }));

})); in lib.fix' (lib.extends overrides packages)
