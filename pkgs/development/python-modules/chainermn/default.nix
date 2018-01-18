{ stdenv, python, buildPythonPackage
, fetchPypi, isPy3k, chainer, cupy, cffi, mpi4py
, mpi, cudatoolkit, cudnn, nccl
, cython, pytest
, cudnnSupport ? false
}:

buildPythonPackage rec {
  pname = "chainermn";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0alggdxkhp5797qjfiid38l8zgcs8f895ygnxp34v3id68xjilyb";
  };

  checkInputs = [
    pytest
  ];

  nativeBuildInputs = [
    cython
  ];

  propagatedBuildInputs = [
    (chainer.override {
      cudaSupport = true;
      cupy = cupy.override {
        cudnnSupport = cudnnSupport;
        ncclSupport = true;
        cudatoolkit = cudatoolkit;
        nccl = nccl;
        cudnn = cudnn;
      };
    })
    (mpi4py.override {
      mpi = mpi;
    })
    cffi
    mpi
  ];

  # In python3, test was failed...
  doCheck = !isPy3k;

  meta = with stdenv.lib; {
    description = "Distributed Deep Learning with Chainer";
    homepage = https://github.com/chainer/chainermn;
    license = licenses.mit;
    maintainers = with maintainers; [ hyphon81 ];
  };
}
