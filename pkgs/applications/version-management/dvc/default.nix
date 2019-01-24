{ lib
, python3Packages
, fetchFromGitHub
, git
, enableGoogle ? false
, enableAWS ? false
, enableAzure ? false
, enableSSH ? false
}:

with python3Packages;
buildPythonApplication rec {
  pname = "dvc";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "iterative";
    repo = "dvc";
    rev = version;
    sha256 = "163lnn8z4ig5dgl2jdkrlqwziyn28shswysq7gpamp8ri0g2ccx3";
  };

  buildInputs = [ git ];

  propagatedBuildInputs = [
    ply
    configparser
    zc_lockfile
    future
    colorama
    configobj
    networkx
    pyyaml
    GitPython
    setuptools
    nanotime
    pyasn1
    schema
    jsonpath_rw
    requests
    grandalf
    asciimatics
    distro
    appdirs
  ]
  ++ lib.optional enableGoogle google_cloud_storage
  ++ lib.optional enableAWS boto3
  ++ lib.optional enableAzure azure-storage-blob
  ++ lib.optional enableSSH paramiko;

  # tests require access to real cloud services
  # nix build tests have to be isolated and run locally
  doCheck = false;

  meta = with lib; {
    description = "Version Control System for Machine Learning Projects";
    license = licenses.asl20;
    homepage = https://dvc.org;
    maintainers = with maintainers; [ cmcdragonkai ];
  };
}
