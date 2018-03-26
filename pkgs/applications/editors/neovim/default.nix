{ stdenv, fetchFromGitHub, cmake, gettext, libmsgpack, libtermkey
, libtool, libuv, ncurses, perl, pkgconfig
, unibilium, vimUtils, xsel, gperf, callPackage
, withJemalloc ? true, jemalloc
, glibcLocales ? null, procps ? null
, withDev ? true
# TODO turn on upon next neovim release
, doCheck ? false
, lua
, python
}:

with stdenv.lib;

let

  # Note: this is NOT the libvterm already in nixpkgs, but some NIH silliness:
  neovimLibvterm = stdenv.mkDerivation rec {
    name = "neovim-libvterm-${version}";
    version = "2017-11-05";

    src = fetchFromGitHub {
      owner = "neovim";
      repo = "libvterm";
      rev = "a9c7c6fd20fa35e0ad3e0e98901ca12dfca9c25c";
      sha256 = "090pyf1n5asaw1m2l9bsbdv3zd753aq1plb0w0drbc2k43ds7k3g";
    };

    buildInputs = [ perl ] ;
    nativeBuildInputs = [ libtool ] ;

    makeFlags = [ "PREFIX=$(out)" ]
      ++ stdenv.lib.optional stdenv.isDarwin "LIBTOOL=${libtool}/bin/libtool";

    enableParallelBuilding = true;

    meta = {
      description = "VT220/xterm/ECMA-48 terminal emulator library";
      homepage = http://www.leonerd.org.uk/code/libvterm/;
      license = licenses.mit;
      maintainers = with maintainers; [ garbas ];
      platforms = platforms.unix;
    };
  };

  neovimLuaEnv =
    lua.withPackages(ps:
    (with ps;
    [ mpack lpeg luabitop ]
    ++ optionals doCheck [ nvim-client luv coxpcall busted luafilesystem penlight  ]
    ++ optionals withDev [ luacheck ]
    ));
in
  stdenv.mkDerivation rec {
    name = "${pname}-${version}";
    pname = "neovim-unwrapped";
    version = "0.2.2";

    src = fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "v${version}";
      sha256 = "1dxr29d0hyag7snbww5s40as90412qb61rgj7gd9rps1iccl9gv4";
    };

    enableParallelBuilding = true;

    buildInputs = [
      libtermkey
      libuv
      libmsgpack
      ncurses
      neovimLibvterm
      unibilium
      gperf
      neovimLuaEnv
    ] ++ optional withJemalloc jemalloc
    ++ optionals doCheck [ glibcLocales procps ]
    ;

    inherit doCheck;

    # to be exhaustive, one could run
    # make oldtests too
    checkPhase = ''
      make functionaltest
    '';

    nativeBuildInputs = [
      cmake
      gettext
      pkgconfig
    ]
      ++ optional withDev python
    ;

    cmakeFlags = [
      "-DLUA_PRG=${neovimLuaEnv}/bin/lua"
    ]
    # for now don't support luajit
    ++ optional (true) "-DPREFER_LUA=ON"
    ++ optional doCheck "-DBUSTED_PRG=${neovimLuaEnv}/bin/busted"
    ;

    # triggers on buffer overflow bug while running tests
    hardeningDisable = [ "fortify" ];

    preConfigure = stdenv.lib.optionalString stdenv.isDarwin ''
      export DYLD_LIBRARY_PATH=${jemalloc}/lib
      substituteInPlace src/nvim/CMakeLists.txt --replace "    util" ""
    '';

    postInstall = stdenv.lib.optionalString stdenv.isLinux ''
      sed -i -e "s|'xsel|'${xsel}/bin/xsel|" $out/share/nvim/runtime/autoload/provider/clipboard.vim
    '' + stdenv.lib.optionalString (withJemalloc && stdenv.isDarwin) ''
      install_name_tool -change libjemalloc.1.dylib \
                ${jemalloc}/lib/libjemalloc.1.dylib \
                $out/bin/nvim
    '';

    meta = {
      description = "Vim text editor fork focused on extensibility and agility";
      longDescription = ''
        Neovim is a project that seeks to aggressively refactor Vim in order to:
        - Simplify maintenance and encourage contributions
        - Split the work between multiple developers
        - Enable the implementation of new/modern user interfaces without any
          modifications to the core source
        - Improve extensibility with a new plugin architecture
      '';
      homepage    = https://www.neovim.io;
      # "Contributions committed before b17d96 by authors who did not sign the
      # Contributor License Agreement (CLA) remain under the Vim license.
      # Contributions committed after b17d96 are licensed under Apache 2.0 unless
      # those contributions were copied from Vim (identified in the commit logs
      # by the vim-patch token). See LICENSE for details."
      license = with licenses; [ asl20 vim ];
      maintainers = with maintainers; [ manveru garbas rvolosatovs ];
      platforms   = platforms.unix;
    };
  }
