{ lib, fetchFromGitHub, python3Packages, makeWrapper, sox, flac, faac, lame
, ffmpeg, vorbis-tools, nodejs, pulseaudio, alsaLib, alsaUtils, youtube-dl
, opusTools, gstreamer, libnotify, glib, dbus-glib, gobject-introspection, wrapGAppsHook
, alsaSupport ? false
, systemTray ? true
, ffmpegSupport ? true
, youtubeSupport ? true
}:

# We define non-python packages here so we can reuse the binding in
# makeSearchPathOutput below.
let packages = [
  vorbis-tools
  sox
  flac
  faac
  lame
  opusTools
  gstreamer
  libnotify
  glib
  dbus-glib
  gobject-introspection
] ++ lib.optional alsaSupport [ alsaLib ffmpeg ]
  ++ lib.optional (!alsaSupport) pulseaudio
  ++ lib.optional ffmpegSupport ffmpeg
  ++ lib.optional youtubeSupport youtube-dl;

in python3Packages.buildPythonApplication rec {
  pname = "mkchromecast";
  version = "0.3.8.1-git";

  src = fetchFromGitHub rec {
    owner = "muammar";
    repo = pname;
    #rev = version;
    rev = "5872a246f0610b74fc2b197eb02dc91b96fb68cc";
    sha256 = "05ldgx583s4b3qqn2r3sj7wjmfdqndkm59g2bwdkpz7pbcahkfmr";
  };

  propagatedBuildInputs = with python3Packages; [
    PyChromecast
    psutil
    mutagen
    flask
    netifaces
    requests
    pygobject3
    dbus-python
  ] ++ lib.optional systemTray pyqt5 ++ packages;

  # Relies on an old version (0.7.7) of PyChromecast unavailable in Nixpkgs.
  doCheck = false;

  # Patch a relative path referring to a Javascript file, to be absolute.
  patchPhase = ''
    sed -i "s_\['\./nodejs_['$out/lib/nodejs_" mkchromecast/video.py
  '';

  buildInputs = [ wrapGAppsHook ];

  makeWrapperArgs = [
      ''--prefix PYTHONPATH : "$out/lib:$PYTHONPATH"''
      ''--prefix PATH : "${lib.makeSearchPathOutput "" "bin" packages}"''
  ];

  postInstall = ''
    wrapProgram "$out/bin/mkchromecast"
  '';

  meta = with lib; {
    homepage = https://github.com/muammar/mkchromecast;
    description = "Cast macOS and Linux Audio/Video to your Google Cast and Sonos Devices";
    license = licenses.mit;
    maintainers = with maintainers; [ shou ];
  };
}
