{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, python2, writeText
, libXext, libX11, xproto, glproto
}:
let
  driverLink = "/run/opengl-driver" + stdenv.lib.optionalString stdenv.isi686 "-32";
  dri_pc = writeText "dri.pc" ''
    dridriverdir=${driverLink}
    Name: dri
    Version: ${fakeVersion}
    Description: Direct Rendering Infrastructure
  '';
  fakeVersion = "12.0.1";

result = stdenv.mkDerivation rec {
  name = "libglvnd-${version}";
  #/*
  version = "0.2pre-${src.rev}";

  src = fetchFromGitHub {
    owner = "vcunat"; #"NVIDIA";
    repo = "libglvnd";
    rev = "243a8b3"; #"14f6283";
    sha256 = "16g5hls17phb1vr3y1hzxr373a4hzilckbab3igf4cq3r9scx7fd";
    #sha256 = "1rsrxyl7iqc5nm6gsdxwsa17glxynvns8irwxsrp00m30b3qg7ic";
  };
  /*/
  src = ../../../../../libglvnd;
  version = "0.2pre-git";
  #*/

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ autoreconfHook pkgconfig python2 ];
  buildInputs = [ libXext libX11 xproto glproto ];

  #preConfigure = "./configure --help && false";

  preBuild = "patchShebangs src/generate";

  enableParallelBuilding = true;

  doCheck = false; # need an X server etc.

  # 1: TODO: get up-to-date headers from Khronos instead.
  # 2: Some packages (xorg-server) are sensitive to the version in gl.pc
  # 3: and to dri.pc for dridriverdir.
  postInstall = ''
    find ./include/ -type d -maxdepth 1 | xargs cp -rv -t "$dev/include/"
    sed 's/^Version:.*$/Version: ${fakeVersion}/' -i "$dev/lib/pkgconfig/gl.pc"
    ln -s '${dri_pc}' "$dev/lib/pkgconfig/dri.pc"
  '';

  passthru = { inherit driverLink; };

  meta = with stdenv.lib; {
    description = "OpenGL vendor-neutral dispatch libraries";
    inherit (src.meta) homepage;
    license = licenses.mit; # almost all of it is under various MIT-like formulations
    platforms = platforms.linux;
    maintainers = [ maintainers.vcunat ];
  };
};

in result

