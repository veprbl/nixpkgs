{ stdenv, fetchurl, fetchFromGitHub, autoreconfHook, file, zlib, libgnurx }:

stdenv.mkDerivation rec {
  pname = "file";
  version = "5.35.0.1"; # not really!

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "e0c3763d7988b16b8169882b664a1839fb967e4e";
    sha256 = "0mcn4605i2dgs485f4x4ay8vvd2vq963k236wgcdji471h07pigz";
  };
  #src = fetchurl {
  #  urls = [
  #    "ftp://ftp.astron.com/pub/file/${name}.tar.gz"
  #    "https://distfiles.macports.org/file/${name}.tar.gz"
  #  ];
  #  sha256 = "0ijm1fabm68ykr1zbx0bxnka5jr3n42sj8y5mbkrnxs0fj0mxi1h";
  #};

  nativeBuildInputs = [ autoreconfHook ] ++ stdenv.lib.optional (stdenv.hostPlatform != stdenv.buildPlatform) file;
  buildInputs = [ zlib ]
              ++ stdenv.lib.optional stdenv.hostPlatform.isWindows libgnurx;

  doCheck = true;

  makeFlags = if stdenv.hostPlatform.isWindows then "FILE_COMPILE=file"
              else null;

  meta = with stdenv.lib; {
    homepage = https://darwinsys.com/file;
    description = "A program that shows the type of files";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
