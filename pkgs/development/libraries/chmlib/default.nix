{stdenv, fetchurl}:

stdenv.mkDerivation {
  name = "chmlib-0.38";
  src = fetchurl {
    url = http://66.93.236.84/~jedwin/projects/chmlib/chmlib-0.38.tar.bz2;
    md5 = "d72661526aaea377ed30e9f58a086964";
  };
}
