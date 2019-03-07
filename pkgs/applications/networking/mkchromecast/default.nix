{ pkgs, stdenv, fetchurl, python3Packages, python3, makeWrapper
, alsaSupport ? false
, systemTray ? true
, ffmpegSupport ? true
, youtubeSupport ? true
}:

python3Packages.buildPythonApplication rec {
  pname = "mkchromecast";
  version = "0.3.8.1";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/muammar/${pname}/archive/${version}.tar.gz";
    sha256 = "1clr02zphpkjnnw5l1mgbjsk5ycqryajnlpb8wfdb5ax72ca7066";
  };

  buildInputs = [ makeWrapper ];

  propagatedBuildInputs = with python3Packages; [
    PyChromecast
    psutil
    mutagen
    flask
    netifaces
    requests
    pkgs.vorbis-tools
    pkgs.sox
    pkgs.flac
    pkgs.faac
    pkgs.lame
    pkgs.ffmpeg
    pkgs.nodejs
    # notify
    pkgs.libnotify
    pygobject3
  ] ++ stdenv.lib.optional alsaSupport [ pkgs.alsaLib pkgs.alsaUtils pkgs.ffmpeg ]
    ++ stdenv.lib.optional (!alsaSupport) pkgs.pulseaudio
    ++ stdenv.lib.optional systemTray python3Packages.pyqt5
    ++ stdenv.lib.optional ffmpegSupport pkgs.ffmpeg
    ++ stdenv.lib.optional youtubeSupport pkgs.youtube-dl;

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
    wrapProgram "$out/bin/mkchromecast" --prefix PYTHONPATH : "$out/lib:$out/lib/mkchromecast/getch:$PYTHONPATH" \
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/muammar/mkchromecast";
    description = "Cast macOS and Linux Audio/Video to your Google Cast and Sonos Devices";
    license = licenses.mit;
    maintainers = with maintainers; [ shou ];
  };
}
