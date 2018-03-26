{ stdenv, fetchurl, fetchpatch, readline
, hostPlatform, makeWrapper
, lua-setup-hook, callPackage
, self
, getLuaPath, getLuaCPath
, luaPackages, packageOverrides ? (self: super: {})
}:

let
  dsoPatch = fetchurl {
    url = "https://projects.archlinux.org/svntogit/packages.git/plain/trunk/lua-arch.patch?h=packages/lua51";
    sha256 = "11fcyb4q55p4p7kdb8yp85xlw8imy14kzamp2khvcyxss4vw8ipw";
    name = "lua-arch.patch";
  };
in
stdenv.mkDerivation rec {
  name = "lua-${version}";
  majorVersion = "5.1";
  version = "${majorVersion}.5";

  # helper functions for dealing with LUA_PATH and LUA_CPATH
  LuaPathSearchPaths    = getLuaPath majorVersion;
  LuaCPathSearchPaths   = getLuaCPath majorVersion;
  setupHook = lua-setup-hook LuaPathSearchPaths LuaCPathSearchPaths;

  src = fetchurl {
    url = "http://www.lua.org/ftp/${name}.tar.gz";
    sha256 = "2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333";
  };

  buildInputs = [ readline ];

  patches = (if stdenv.isDarwin then [ ./5.1.darwin.patch ] else [ dsoPatch ])
    ++ [(fetchpatch {
      name = "CVE-2014-5461.patch";
      url = "http://anonscm.debian.org/cgit/pkg-lua/lua5.1.git/plain/debian/patches/"
        + "0004-Fix-stack-overflow-in-vararg-functions.patch?id=b75a2014db2ad65683521f7bb295bfa37b48b389";
      sha256 = "05i5vh53d9i6dy11ibg9i9qpwz5hdm0s8bkx1d9cfcvy80cm4c7f";
    })];

  configurePhase =
    if stdenv.isDarwin
    then ''
    makeFlagsArray=( INSTALL_TOP=$out INSTALL_MAN=$out/share/man/man1 PLAT=macosx CFLAGS="-DLUA_USE_LINUX -fno-common -O2" LDFLAGS="" CC="$CC" )
    installFlagsArray=( TO_BIN="lua luac" TO_LIB="liblua.5.1.5.dylib" INSTALL_DATA='cp -d' )
  '' else ''
    makeFlagsArray=( INSTALL_TOP=$out INSTALL_MAN=$out/share/man/man1 PLAT=linux CFLAGS="-DLUA_USE_LINUX -O2 -fPIC" LDFLAGS="-fPIC" CC="$CC" AR="$AR q" RANLIB="$RANLIB" )
    installFlagsArray=( TO_BIN="lua luac" TO_LIB="liblua.a liblua.so liblua.so.5.1 liblua.so.5.1.5" INSTALL_DATA='cp -d' )
  '';

  postInstall = ''
    mkdir -p "$out/share/doc/lua" "$out/lib/pkgconfig"
    sed <"etc/lua.pc" >"$out/lib/pkgconfig/lua.pc" -e "s|^prefix=.*|prefix=$out|"
    mv "doc/"*.{gif,png,css,html} "$out/share/doc/lua/"
    rmdir $out/{share,lib}/lua/5.1 $out/{share,lib}/lua
  '';

  passthru = let
    luaPackages = callPackage ../../../top-level/lua-packages.nix {lua=self; overrides=packageOverrides;};
  in rec {
    buildEnv = callPackage ./wrapper.nix { lua=self;
    inherit (luaPackages) requiredLuaModules;
    };
    withPackages = import ./with-packages.nix { inherit buildEnv luaPackages;};
    pkgs = luaPackages;
    interpreter = "${self}/bin/lua";
  };

  meta = {
    homepage = http://www.lua.org;
    description = "Powerful, fast, lightweight, embeddable scripting language";
    longDescription = ''
      Lua combines simple procedural syntax with powerful data
      description constructs based on associative arrays and extensible
      semantics. Lua is dynamically typed, runs by interpreting bytecode
      for a register-based virtual machine, and has automatic memory
      management with incremental garbage collection, making it ideal
      for configuration, scripting, and rapid prototyping.
    '';
    license = stdenv.lib.licenses.mit;
    platforms = stdenv.lib.platforms.linux;
    hydraPlatforms = stdenv.lib.platforms.linux;
  };
}
