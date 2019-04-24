{ lib, python3Packages, gtk3, gobject-introspection, ffmpeg, which, wrapGAppsHook }:

with python3Packages;
buildPythonApplication rec {
  pname = "gnomecast";
  version = "1.7.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0hss7m9chqjhdzbvxs8kr312izb5diz85nfv7c050gpslk5mkr0v";
  };

  nativeBuildInputs = [ wrapGAppsHook ];
  propagatedBuildInputs = [
    PyChromecast bottle pycaption paste html5lib pygobject3 dbus-python
    gtk3 gobject-introspection
  ];

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ ffmpeg which ]})
  '';

  meta = with lib; {
    description = "A native Linux GUI for Chromecasting local files";
    homepage = https://github.com/keredson/gnomecast;
    license = with licenses; [ gpl3 ];
  };
}
