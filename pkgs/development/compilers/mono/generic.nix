{ stdenv, fetchurl, bison, glib, gettext, perl, libgdiplus, libX11, ncurses, zlib
, cacert, Foundation, libobjc, python, version, sha256
, cmake, which, pkgconfig, autoreconfHook
, withLLVM ? stdenv.hostPlatform.is64bit, callPackage
, withNinja ? true, ninja
, enableParallelBuilding ? true }:

let
  llvm = callPackage ./llvm.nix {};
in
stdenv.mkDerivation rec {
  name = "mono-${version}";

  src = fetchurl {
    inherit sha256;
    url = "https://download.mono-project.com/sources/mono/${name}.tar.bz2";
  };

  nativeBuildInputs = [ cmake pkgconfig which perl python autoreconfHook  ninja ];

  dontUseNinjaBuild = true;
  dontUseNinjaInstall = true;

  buildInputs =
    [ bison glib gettext libgdiplus libX11 ncurses zlib 
    ]
    ++ (stdenv.lib.optionals stdenv.isDarwin [ Foundation libobjc ]);

  propagatedBuildInputs = [glib];

  NIX_LDFLAGS = if stdenv.isDarwin then "" else "-lgcc_s" ;

  # To overcome the bug https://bugzilla.novell.com/show_bug.cgi?id=644723
  dontDisableStatic = true;

  autoreconfPhase = ''
    patchShebangs ./
    NOCONFIGURE=1 ./autogen.sh
  '';

  configureFlags = [
    "--x-includes=${libX11.dev}/include"
    "--x-libraries=${libX11.out}/lib"
    "--with-libgdiplus=${libgdiplus}/lib/libgdiplus.so"
    "--with-large-heap=yes" # for heaps larger than 3GB
  ]
  ++ stdenv.lib.optionals withLLVM [
    "--enable-llvm"
    "--with-llvm=${llvm}"
  ];


  # Attempt to fix this error when running "mcs --version":
  # The file /nix/store/xxx-mono-2.4.2.1/lib/mscorlib.dll is an invalid CIL image
  dontStrip = true;

  dontUseCmakeConfigure = true;

  # We want pkg-config to take priority over the dlls in the Mono framework and the GAC
  # because we control pkg-config
  patches = [ ./pkgconfig-before-gac.patch ];

  # Patch all the necessary scripts. Also, if we're using LLVM, we fix the default
  # LLVM path to point into the Mono LLVM build, since it's private anyway.
  preBuild = ''
    makeFlagsArray=(INSTALL=`type -tp install`)
    substituteInPlace mcs/class/corlib/System/Environment.cs --replace /usr/share "$out/share"
  '' + stdenv.lib.optionalString withLLVM ''
    substituteInPlace mono/mini/aot-compiler.c --replace "llvm_path = g_strdup (\"\")" "llvm_path = g_strdup (\"${llvm}/bin/\")"
  '' +
  # upstream frequently pushes tarballs with compiled files,
  # which we don't want and in some cases (cross) are just wrong.
  # Remove them now.  Upstream issue 14179.
  (let
    dotExts = [ "libs" "deps" "so" "lo" "Plo" "dirstamp" ];
    matchargs = stdenv.lib.concatMapStringsSep " -o " (ext: ''-path '*\.${ext}' '') dotExts;
  in ''
    find external ${matchargs} -delete
  '');

  # Fix mono DLLMap so it can find libX11 to run winforms apps
  # libgdiplus is correctly handled by the --with-libgdiplus configure flag
  # Other items in the DLLMap may need to be pointed to their store locations, I don't think this is exhaustive
  # https://www.mono-project.com/Config_DllMap
  postBuild = ''
    find . -name 'config' -type f | xargs \
    sed -i -e "s@libX11.so.6@${libX11.out}/lib/libX11.so.6@g"
  '';

  # Without this, any Mono application attempting to open an SSL connection will throw with
  # The authentication or decryption has failed.
  # ---> Mono.Security.Protocol.Tls.TlsException: Invalid certificate received from server.
  postInstall = ''
    echo "Updating Mono key store"
    $out/bin/cert-sync ${cacert}/etc/ssl/certs/ca-bundle.crt
  ''
  # According to [1], gmcs is just mcs
  # [1] https://github.com/mono/mono/blob/master/scripts/gmcs.in
  + ''
    ln -s $out/bin/mcs $out/bin/gmcs
  '';

  inherit enableParallelBuilding;

  meta = with stdenv.lib; {
    homepage = https://mono-project.com/;
    description = "Cross platform, open source .NET development framework";
    platforms = with platforms; darwin ++ linux;
    maintainers = with maintainers; [ thoughtpolice obadz vrthra ];
    license = licenses.free; # Combination of LGPL/X11/GPL ?
  };
}
