{ stdenv, fetchurl, 
  CoreServices, Foundation, ForceFeedback, AppKit, OpenGL, IOKit, DiskArbitration, Security, ApplicationServices, AudioToolbox, CoreAudio, AudioUnit, CoreMIDI, OpenAL, OpenCL, Cocoa, Carbon,
  flex, bison, libX11, freetype}:

stdenv.mkDerivation rec {

  name = "wine-${version}";
  version = "2.0.2";
  src = fetchurl {
    url = "https://dl.winehq.org/wine/source/2.0/wine-${version}.tar.xz";
    sha256 = "16iwf48cfi39aqyy8131jz4x7lr551c9yc0mnks7g24j77sq867p";
  };

  buildInputs = with stdenv.lib; [
    flex
    bison
    CoreServices
    Foundation
    ForceFeedback
    AppKit
    OpenGL
    IOKit
    DiskArbitration
    Security
    ApplicationServices
    AudioToolbox
    CoreAudio
    AudioUnit
    CoreMIDI
    OpenAL
    OpenCL
    Cocoa
    Carbon
    freetype
    libX11
  ];
  hardeningDisable = [ "fortify" ];
  configureFlags = [
    "--enable-win64"
  ];
  meta = with stdenv.lib; {
    description = "wine";
    platforms = platforms.darwin;
  };
}
