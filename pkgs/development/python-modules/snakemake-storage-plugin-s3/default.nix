{ lib
, buildPythonPackage
, fetchFromGitHub
, poetry-core
, boto3
, botocore
, snakemake-interface-common
, snakemake-interface-storage-plugins
}:

buildPythonPackage rec {
  pname = "snakemake-storage-plugin-s3";
  version = "0.2.8";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "snakemake";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-Z2cMneJIhGQSbhQt8Jk3QNAM2LR1zc5jUyTL2Q4AViM=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    boto3
    botocore
    snakemake-interface-common
    snakemake-interface-storage-plugins
  ];

  # cicular dependency on snakemake
  #pythonImportsCheck = [ "snakemake_storage_plugin_s3" ];
  doCheck = false;

  meta = with lib; {
    description = "A Snakemake storage plugin for S3 API storage (AWS S3, MinIO, etc.)";
    homepage = "https://github.com/snakemake/snakemake-storage-plugin-s3";
    license = licenses.mit;
    maintainers = with maintainers; [ veprbl ];
  };
}
