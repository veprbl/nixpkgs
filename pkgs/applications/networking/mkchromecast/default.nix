{ lib, fetchFromGitHub, python3Packages, makeWrapper, sox, flac, faac, lame
, ffmpeg, vorbis-tools, nodejs, pulseaudio, alsaLib, alsaUtils, youtube-dl
, opusTools, gstreamer
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
] ++ lib.optional alsaSupport [ alsaLib ffmpeg ]
  ++ lib.optional (!alsaSupport) pulseaudio
  ++ lib.optional ffmpegSupport ffmpeg
  ++ lib.optional youtubeSupport youtube-dl;

in python3Packages.buildPythonApplication rec {
  pname = "mkchromecast";
  version = "0.3.8.1";

  src = fetchFromGitHub rec {
    owner = "muammar";
    repo = pname;
    rev = version;
    sha256 = "0baxilfalndip3fx8cj03pjkdywv1v65k41srarcdrzvm8dqca9s";
  };

  propagatedBuildInputs = with python3Packages; [
    PyChromecast
    psutil
    mutagen
    flask
    netifaces
    requests
  ] ++ lib.optional systemTray pyqt5;

  # Build instructions are macOS specific in 0.3.8.1;
  # master has Linux build instructions but awaiting new release.
  dontBuild = true;

  format = "other";

  # Relies on an old version (0.7.7) of PyChromecast unavailable in Nixpkgs.
  doCheck = false;

  # Patch a relative path referring to a Javascript file, to be absolute.
  patchPhase = ''
    sed -i "s_\['\./nodejs_['$out/lib/nodejs_" mkchromecast/video.py
  '';

  makeWrapperArgs = [
      ''--prefix PYTHONPATH : "$out/lib:$PYTHONPATH"''
      ''--prefix PATH : "${lib.makeSearchPathOutput "" "bin" packages}"''
  ];

  installPhase = ''
    env
    install -Dm 644 man/mkchromecast.1 $out/share/man/man1/mkchromecast.1
    install -Dm 644 mkchromecast.desktop $out/share/applications/mkchromecast.desktop
    install -Dm 644 -t $out/lib/mkchromecast mkchromecast/*.py
    install -Dm 644 -t $out/lib/mkchromecast/getch mkchromecast/getch/*.py
    install -Dm 644 nodejs/html5-video-streamer.js $out/lib/nodejs/html5-video-streamer.js
    install -Dm 644 -t $out/share/images/ images/google*.png
    install -Dm 644 images/mkchromecast.xpm $out/share/pixmaps/mkchromecast.xpm
    install -Dm 755 mkchromecast.py $out/bin/mkchromecast
    wrapProgram "$out/bin/mkchromecast"
  '';

  meta = with lib; {
    homepage = https://github.com/muammar/mkchromecast;
    description = "Cast macOS and Linux Audio/Video to your Google Cast and Sonos Devices";
    license = licenses.mit;
    maintainers = with maintainers; [ shou ];
  };
}
