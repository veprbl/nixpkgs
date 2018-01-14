{ stdenv, fetchFromGitHub, cmake, boost, qt4 ? null, qtbase ? null, latestGitHubRelease }:

# Only one qt
assert qt4 != null -> qtbase == null;
assert qtbase != null -> qt4 == null;

let
  version = "0.1.1";
  srcinfo = {
    owner = "yegord";
    repo = "snowman";
    rev = "v${version}";
    sha256 = "0bzqp3zc101dzvybf57bj4dvnybvds0lmn1w2xjb19wkzm9liskn";
  };

in stdenv.mkDerivation rec {
  name = "snowman-${version}";
  inherit version;

  src = fetchFromGitHub srcinfo;
  nativeBuildInputs = [ cmake ];

  buildInputs = [ boost qt4 qtbase ];

  postUnpack = ''
    export sourceRoot=$sourceRoot/src
  '';

  enableParallelBuilding = true;

  passthru.updateScript = latestGitHubRelease "snowman" srcinfo;

  meta = with stdenv.lib; {
    description = "Native code to C/C++ decompiler";
    homepage = "http://derevenets.com/";

    # https://github.com/yegord/snowman/blob/master/doc/licenses.asciidoc
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}
