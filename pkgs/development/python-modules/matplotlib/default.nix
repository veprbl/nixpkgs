{ stdenv, fetchPypi, fetchzip, fetchFromGitHub, python, buildPythonPackage, isPy3k, pycairo, backports_functools_lru_cache
, which, cycler, dateutil, nose, numpy, pyparsing, sphinx, tornado, kiwisolver
, freetype, libpng, pkgconfig, mock, pytz, pygobject3, gobject-introspection
, pytest, pytestCheckHook
, enableGhostscript ? true, ghostscript ? null, gtk3
, enableGtk3 ? false, cairo
# darwin has its own "MacOSX" backend
, enableTk ? !stdenv.isDarwin, tcl ? null, tk ? null, tkinter ? null, libX11 ? null
, enableQt ? false, pyqt5 ? null
, libcxx
, Cocoa
, pythonOlder
}:

assert enableGhostscript -> ghostscript != null;
assert enableTk -> (tcl != null)
                && (tk != null)
                && (tkinter != null)
                && (libX11 != null)
                ;
assert enableQt -> pyqt5 != null;

buildPythonPackage rec {
  version = "3.2.1";
  pname = "matplotlib";

  disabled = !isPy3k;

  _src = fetchPypi {
    inherit pname version;
    sha256 = "ffe2f9cdcea1086fc414e82f42271ecf1976700b8edd16ca9d376189c6d93aee";
  };

  src = fetchFromGitHub {
    owner = "matplotlib";
    repo = pname;
    rev = "v${version}";
    sha256 = "0wk4qahmpmvl47qq1vqh99lsyrhaflbwb2bqg2f2m0qj6spnmp16";
  };

  jquery = fetchzip {
    url = "https://jqueryui.com/resources/download/jquery-ui-1.12.1.zip";
    sha256 = "14g4zv4pzpimnirz6sn5l823p3lfva3x2009dyliy5ccdav5i4w5";
    stripRoot = false;
  };

  freetype = fetchzip {
    url = "https://download.savannah.gnu.org/releases/freetype/freetype-2.6.1.tar.gz";
    sha256 = "13ilnhar7wm2jvnkkz7q2zhb115qpaahrnpc80z018w0vddgjiyd";
    stripRoot = false;
  };

  preBuild = ''
    cp -r "$jquery"/* lib/matplotlib/backends/web_backend/
    mkdir -p build
    cp -r "$freetype"/* build/
    chmod -R +w build/


echo $PYTHONPATH
cat > setup.cfg <<EOF
[directories]
basedirlist = ./
[packages]
tests = True
toolkit_tests = True
sample_data = True
[test]
local_freetype = True
EOF
  '';
  
  #NIX_CFLAGS_COMPILE = stdenv.lib.optionalString stdenv.isDarwin "-I${libcxx}/include/c++/v1";

  XDG_RUNTIME_DIR = "/tmp";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ python which sphinx stdenv ]
    ++ stdenv.lib.optional enableGhostscript ghostscript
    ++ stdenv.lib.optional stdenv.isDarwin [ Cocoa ];

  propagatedBuildInputs =
    [ cycler dateutil numpy pyparsing tornado freetype kiwisolver
      libpng mock pytz ]
    ++ stdenv.lib.optional (pythonOlder "3.3") backports_functools_lru_cache
    ++ stdenv.lib.optionals enableGtk3 [ cairo pycairo gtk3 gobject-introspection pygobject3 ]
    ++ stdenv.lib.optionals enableTk [ tcl tk tkinter libX11 ]
    ++ stdenv.lib.optionals enableQt [ pyqt5 ];

  checkInputs = [ pytestCheckHook ];

#  patches =
#    [ ./basedirlist.patch ];

  # Matplotlib tries to find Tcl/Tk by opening a Tk window and asking the
  # corresponding interpreter object for its library paths. This fails if
  # `$DISPLAY` is not set. The fallback option assumes that Tcl/Tk are both
  # installed under the same path which is not true in Nix.
  # With the following patch we just hard-code these paths into the install
  # script.
  postPatch =
    let
      inherit (stdenv.lib.strings) substring;
      tcl_tk_cache = ''"${tk}/lib", "${tcl}/lib", "${substring 0 3 tk.version}"'';
    in
    stdenv.lib.optionalString enableTk
      "sed -i '/self.tcl_tk_cache = None/s|None|${tcl_tk_cache}|' setupext.py";

  dontUseSetuptoolsCheck = true;
  preCheck = ''
#    ln -s $src/lib/matplotlib/tests/baseline_images $out/lib/python3.7/site-packages/matplotlib/tests
cd $out/lib/python3.7/site-packages/matplotlib
echo $PYTHONPATH
export src=
export OLDPWD=
export jquery=
echo ===============
env | grep source
echo ===============
grep -r 274m6fjlqfcar7wvwjz3hcyq2dv8v5yd $out || true
  '';
  checkPhase = ''
runHook preCheck
pytest
'';
  pytestFlagsArray = [ "; pwd" ];
  _checkPhase = ''
echo $PYTHONPATH
    ${python.interpreter} tests.py
  '';

  # Test data is not included in the distribution (the `tests` folder
  # is missing)
  doCheck = true;

  prePatch = ''
    # Transient errors
    sed -i 's/test_invisible_Line_rendering/noop/' lib/matplotlib/tests/test_lines.py
  '';

  meta = with stdenv.lib; {
    description = "Python plotting library, making publication quality plots";
    homepage    = "https://matplotlib.org/";
    maintainers = with maintainers; [ lovek323 ];
  };

}
