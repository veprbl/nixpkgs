{ lib, stdenv, fetchFromGitHub, cmake, libexecinfo }:

stdenv.mkDerivation rec {
  pname = "aws-c-common";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "awslabs";
    repo = pname;
    rev = "v${version}";
    sha256 = "0wfqs77plb37gp586a0pclxjlpsjvq44991am8p2g5j46zfz6pdx";
  };

  nativeBuildInputs = [ cmake ];

  # TODO: to fix w/musl, use libexecinfo
  # and add 'execinfo' to system libs needed (see CMakeLists.txt, as done w/FreeBSD)
  #buildInputs = [ libexecinfo ];

  NIX_CFLAGS_COMPILE = lib.optionals stdenv.isDarwin [
    "-Wno-nullability-extension"
    "-Wno-typedef-redefinition"
  ];

  meta = with lib; {
    description = "AWS SDK for C common core";
    homepage = https://github.com/awslabs/aws-c-common;
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = with maintainers; [ orivej eelco ];
  };
}
