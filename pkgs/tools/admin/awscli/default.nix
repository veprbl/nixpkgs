{ lib
, python
, groff
, less
}:

let
  py = python;

in py.pkgs.buildPythonApplication rec {
  pname = "awscli";
  version = "1.16.47";

  src = py.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "678d178e05440b4912d218d81feb2106b59050d7435f4f424c45afb9906113da";
  };

  # No tests included
  doCheck = false;

  propagatedBuildInputs = with py.pkgs; [
    botocore
    bcdoc
    s3transfer
    six
    colorama
    docutils
    rsa
    pyyaml
    groff
    less
  ];

  postInstall = ''
    mkdir -p $out/etc/bash_completion.d
    echo "complete -C $out/bin/aws_completer aws" > $out/etc/bash_completion.d/awscli
    mkdir -p $out/share/zsh/site-functions
    mv $out/bin/aws_zsh_completer.sh $out/share/zsh/site-functions
    rm $out/bin/aws.cmd
  '';

  meta = with lib; {
    homepage = https://aws.amazon.com/cli/;
    description = "Unified tool to manage your AWS services";
    license = licenses.asl20;
    maintainers = with maintainers; [ muflax ];
  };
}
