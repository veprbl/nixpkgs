{ lib, pythonPackages, fetchFromGitHub }:

pythonPackages.buildPythonApplication rec {
  pname = "outputcheck";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "stp";
    repo = pname;
    rev = version;
    sha256 = "1y27vz6jq6sywas07kz3v01sqjd0sga9yv9w2cksqac3v7wmf2a0";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "version=version.get_git_version()" \
                "version='${version}'"
  '';

  meta = {
    description = "Tool for checking tool output inspired by LLVM's FileCheck";
    homepage = https://github.com/stp/OutputCheck;
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dtzWill ];
  };
}

