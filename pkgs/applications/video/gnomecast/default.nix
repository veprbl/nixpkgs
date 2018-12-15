{ lib, python3Packages, gtk3, gobject-introspection, ffmpeg, wrapGAppsHook }:

with python3Packages;
buildPythonApplication rec {
  pname = "gnomecast";
  version = "1.5.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "04wa6mphz4ap2iahgh747ml2lxfax35l5byla5i86d04f2f1aiwr";
  };

  nativeBuildInputs = [ wrapGAppsHook ];
  propagatedBuildInputs = [
    PyChromecast bottle pycaption paste html5lib pygobject3 dbus-python
    gtk3 gobject-introspection
  ];

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ ffmpeg ]})
  '';

  meta = with lib; {
    description = "A native Linux GUI for Chromecasting local files";
    homepage = https://github.com/keredson/gnomecast;
    license = with licenses; [ gpl3 ];
  };
}
