{ stdenv, fetchFromGitHub, cmake, makeWrapper, itk, vtk }:

stdenv.mkDerivation rec {
  _name    = "ANTs";
  _version = "2.3.1";
  name  = "${_name}-${_version}";

  src = fetchFromGitHub {
    owner  = "ANTsX";
    repo   = "ANTs";
    rev    = "refs/tags/v${_version}";
    sha256 = "095n6pnjj6bjxmximwz7yjldisq2k3d3pz3lk8nlmq1r9gsi5zqw";
  };

  nativeBuildInputs = [ cmake makeWrapper ];
  buildInputs = [ itk vtk ];

  cmakeFlags = [ "-DANTS_SUPERBUILD=FALSE" "-DUSE_VTK=TRUE" ];

  enableParallelBuilding = true;

  postInstall = ''
    for file in $out/bin/*; do
      wrapProgram $file --set ANTSPATH "$out/bin"
    done
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/ANTxS/ANTs;
    description = "Advanced normalization toolkit for medical image registration and other processing";
    maintainers = with maintainers; [ bcdarwin ];
    platforms = platforms.unix;
    license = licenses.bsd3;
  };
}
