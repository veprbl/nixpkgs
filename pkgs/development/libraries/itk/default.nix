{ stdenv, fetchFromGitHub, cmake, libX11, libuuid, xz, vtk }:

stdenv.mkDerivation rec {
  pname = "itk";
  version = "5.0rc02";

  src = fetchFromGitHub {
    owner = "InsightSoftwareConsortium";
    repo = pname;
    rev = "refs/tags/v${version}";
    sha256 = "1ia7smvf72lcy9n4wj98275mj5k6y2hlqbi4y1sympnlfh9w29mz";
  };

  cmakeFlags = [
    "-DBUILD_EXAMPLES=OFF"
    "-DBUILD_SHARED_LIBS=ON"
    "-DModule_ITKMINC=ON"
    "-DModule_ITKIOMINC=ON"
    "-DModule_ITKIOTransformMINC=ON"
    "-DModule_ITKVtkGlue=ON"
    "-DModule_ITKReview=ON"
  ];

  enableParallelBuilding = true;

  nativeBuildInputs = [ cmake xz ];
  buildInputs = [ libX11 libuuid vtk ];

  meta = {
    description = "Insight Segmentation and Registration Toolkit";
    homepage = http://www.itk.org/;
    license = stdenv.lib.licenses.asl20;
    maintainers = with stdenv.lib.maintainers; [viric];
    platforms = with stdenv.lib.platforms; linux ++ darwin;
  };
}
