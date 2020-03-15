{ fetchurl
, stdenv
, meson
, ninja
, pkgconfig
, gnome3
, gtk3
, atk
, gobject-introspection
, spidermonkey_68
, pango
, cairo
, readline
, glib
, libxml2
, dbus
, gdk-pixbuf
, makeWrapper
, nixosTests
}:

stdenv.mkDerivation rec {
  pname = "gjs";
  version = "1.64.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gjs/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "0vynivp1d10jkxfcgb5vcjkba5dvi7amkm8axmyad7l4dfy4qf36";
  };

  outputs = [ "out" "dev" "installedTests" ];

  nativeBuildInputs = [
    meson
    ninja
    pkgconfig
    makeWrapper
    libxml2 # for xml-stripblanks
  ];

  buildInputs = [
    gobject-introspection
    cairo
    readline
    spidermonkey_68
    dbus # for dbus-run-session
  ];

  propagatedBuildInputs = [
    glib
  ];

  mesonFlags = [
    "-Dprofiler=disabled"
    "-Dinstalled_test_prefix=${placeholder "installedTests"}"
  ];

  patches = [
    # Hard-code various paths
    ./fix-paths.patch

    # Clean-ups to make installing installed tests separately easier.
    # https://gitlab.gnome.org/GNOME/gjs/-/merge_requests/403
    ./meson-tests-cleanups.patch

    # Allow installing installed tests to a separate output.
    ./installed-tests-path.patch
  ];

  postPatch = ''
    substituteInPlace installed-tests/debugger-test.sh --subst-var-by gjsConsole $out/bin/gjs-console
  '';

  postInstall = ''
    wrapProgram "$installedTests/libexec/gjs/installed-tests/minijasmine" \
      --prefix GI_TYPELIB_PATH : "${stdenv.lib.makeSearchPath "lib/girepository-1.0" [ gtk3 glib atk pango.out gdk-pixbuf ]}"
  '';

  separateDebugInfo = stdenv.isLinux;

  passthru = {
    tests = {
      installed-tests = nixosTests.installed-tests.gjs;
    };

    updateScript = gnome3.updateScript {
      packageName = "gjs";
    };
  };

  meta = with stdenv.lib; {
    description = "JavaScript bindings for GNOME";
    homepage = "https://gitlab.gnome.org/GNOME/gjs/blob/master/doc/Home.md";
    license = licenses.lgpl2Plus;
    maintainers = gnome3.maintainers;
    platforms = platforms.linux;
  };
}
