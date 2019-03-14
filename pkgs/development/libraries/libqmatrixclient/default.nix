{ stdenv, fetchFromGitHub, cmake
, qtbase, qtmultimedia }:

stdenv.mkDerivation rec {
  pname = "libqmatrixclient";
  version = "0.5.0.2";

  src = fetchFromGitHub {
    owner  = "QMatrixClient";
    repo   = pname;
    rev    = version;
    sha256 = "1p9yg7nbkiprrnng2rjclz6dxacma5spm9waj5fafl7ikh65xf17";
  };

  buildInputs = [ qtbase qtmultimedia ];

  nativeBuildInputs = [ cmake ];

  meta = with stdenv.lib; {
    description= "A Qt5 library to write cross-platfrom clients for Matrix";
    homepage = https://matrix.org/docs/projects/sdk/libqmatrixclient.html;
    license = licenses.lgpl21;
    platforms = with platforms; linux ++ darwin;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
