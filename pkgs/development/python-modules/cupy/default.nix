{ stdenv, lib, python, buildPythonPackage
, fetchPypi, isPy3k, linuxPackages, gcc5
, fastrlock, numpy, six, wheel, pytest, mock
, cudatoolkit, cudatoolkit8, cudnn, cudnn_cudatoolkit8, nccl
, cudnnSupport ? true, ncclSupport ? false
}:

buildPythonPackage rec {
  pname = "cupy";
  version = "2.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0si0ri8azxvxh3lpm4l4g60jf4nwzibi53yldbdbzb1svlqq060r";
  };

  checkInputs = [
    pytest
    mock
  ];

  nativeBuildInputs = [
    gcc5
  ] ++ lib.optionals ncclSupport [
    cudatoolkit8
  ] ++ lib.optionals (!ncclSupport) [
    cudatoolkit
  ];

  propagatedBuildInputs = [
    linuxPackages.nvidia_x11
    fastrlock
    numpy
    six
    wheel
  ] ++ lib.optionals ncclSupport [
    nccl
    cudatoolkit8
  ] ++ lib.optionals (ncclSupport && cudnnSupport) [
    cudnn_cudatoolkit8
  ] ++ lib.optionals (!ncclSupport && cudnnSupport) [
    cudnn
  ] ++ lib.optionals (!ncclSupport) [
    cudatoolkit
  ];

  # In python3, test was failed...
  doCheck = !isPy3k;

  meta = with stdenv.lib; {
    description = "A NumPy-compatible matrix library accelerated by CUDA";
    homepage = https://cupy.chainer.org/;
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ hyphon81 ];
  };
}
