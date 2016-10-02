{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, python2
, libXext, libX11, xproto, glproto
}:

stdenv.mkDerivation rec {
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

  # TODO: get up-to-date headers from Khronos instead
  postInstall = ''
    find ./include/ -type d -maxdepth 1 | xargs cp -rv -t "$dev/include/"
  '';

  meta = with stdenv.lib; {
    description = "OpenGL vendor-neutral dispatch libraries";
    inherit (src.meta) homepage;
    license = licenses.mit; # almost all of it is under various MIT-like formulations
    platforms = platforms.linux;
    maintainers = [ maintainers.vcunat ];
  };
}
