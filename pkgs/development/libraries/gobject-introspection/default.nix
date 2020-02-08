{ stdenv, fetchurl, glib, flex, bison, meson, ninja, pkgconfig, libffi, python3
, libintl, cctools, cairo, gnome3, glibcLocales
, substituteAll, nixStoreDir ? builtins.storeDir
, x11Support ? true
}:
# now that gobject-introspection creates large .gir files (eg gtk3 case)
# it may be worth thinking about using multiple derivation outputs
# In that case its about 6MB which could be separated

with stdenv.lib;
stdenv.mkDerivation rec {
  pname = "gobject-introspection";
  version = "1.64.0";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "10pwykfnk7pw8k9k8iz3p72phxvyrh5q4d7gr3ysv08w15immh7a";
  };

  outputs = [ "out" "dev" "man" ];
  outputBin = "dev";

  LC_ALL = "en_US.UTF-8"; # for tests

  nativeBuildInputs = [ meson ninja pkgconfig libintl glibcLocales ];
  buildInputs = [ flex bison python3 setupHook/*move .gir*/ ]
    ++ stdenv.lib.optional stdenv.isDarwin cctools;
  propagatedBuildInputs = [ libffi glib ];

  mesonFlags = [
    "--datadir=${placeholder "dev"}/share"
    "-Ddoctool=disabled"
    "-Dcairo=disabled"
  ];

  # outputs TODO: share/gobject-introspection-1.0/tests is needed during build
  # by pygobject3 (and maybe others), but it's only searched in $out

  setupHook = ./setup-hook.sh;

  patches = [
    # the gitypelibtest fails as the required libs aren't installed yet
    ./disabled_tests.patch
    (substituteAll {
      src = ./test_shlibs.patch;
      inherit nixStoreDir;
    })
    (substituteAll {
      src = ./absolute_shlib_path.patch;
      inherit nixStoreDir;
    })
  ] ++ stdenv.lib.optional x11Support # https://github.com/NixOS/nixpkgs/issues/34080
    (substituteAll {
      src = ./absolute_gir_path.patch;
      cairoLib = "${getLib cairo}/lib";
    });

  doCheck = !stdenv.isAarch64;

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
    };
  };

  meta = with stdenv.lib; {
    description = "A middleware layer between C libraries and language bindings";
    homepage    = http://live.gnome.org/GObjectIntrospection;
    maintainers = with maintainers; [ lovek323 lethalman ];
    platforms   = platforms.unix;
    license = with licenses; [ gpl2 lgpl2 ];

    longDescription = ''
      GObject introspection is a middleware layer between C libraries (using
      GObject) and language bindings. The C library can be scanned at compile
      time and generate a metadata file, in addition to the actual native C
      library. Then at runtime, language bindings can read this metadata and
      automatically provide bindings to call into the C library.
    '';
  };
}
