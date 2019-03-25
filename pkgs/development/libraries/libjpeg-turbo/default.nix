{ stdenv, fetchurl, fetchpatch, cmake, nasm }:

stdenv.mkDerivation rec {
  pname = "libjpeg-turbo";
  version = "2.0.2";

  src = fetchurl {
    url = "mirror://sourceforge/${pname}/${pname}-${version}.tar.gz";
    sha256 = "1v9gx1gdzgxf51nd55ncq7rghmj4x9x91rby50ag36irwngmkf5c";
  };

  patches =
    stdenv.lib.optional (stdenv.hostPlatform.libc or null == "msvcrt")
      ./mingw-boolean.patch
  ++ [
    ./djpeg-rgb-islow-icc-cmp.patch # https://github.com/libjpeg-turbo/libjpeg-turbo/pull/321
    (fetchpatch {
      name = "cve-2018-19664.diff";
      url = "https://github.com/libjpeg-turbo/libjpeg-turbo/commit/f8cca819a4fb.diff";
      sha256 = "1kgfag62qmphlrq0mz15g17zw7zrg9nzaz7d2vg50m6m7m5aw4y5";
    })
    (fetchpatch {
      name = "CVE-2018-20330.patch";
      url = "https://github.com/libjpeg-turbo/libjpeg-turbo/commit/3d9c64e9f8aa1ee954d1d0bb3390fc894bb84da3.diff";
      sha256 = "1jai8izw6xl05ihx24rpc96d1jcr9rp421cb02pbz3v53cxdasji";
    })
  ];

  outputs = [ "bin" "dev" "out" "man" "doc" ];

  nativeBuildInputs = [ cmake nasm ];

  cmakeFlags = [ "-DCMAKE_INSTALL_BINDIR=${placeholder "bin"}/bin" "-DENABLE_STATIC=0" ];

  doCheck = true; # not cross;
  checkTarget = "test";

  meta = with stdenv.lib; {
    homepage = http://libjpeg-turbo.virtualgl.org/;
    description = "A faster (using SIMD) libjpeg implementation";
    license = licenses.ijg; # and some parts under other BSD-style licenses
    maintainers = [ maintainers.vcunat ];
    platforms = platforms.all;
  };
}
