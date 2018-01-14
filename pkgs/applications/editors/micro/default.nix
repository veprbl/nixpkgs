{ stdenv, buildGoPackage, fetchFromGitHub, latestGitHubRelease }:

let
  version = "1.3.4";
  srcinfo = {
    owner = "zyedidia";
    repo = "micro";
    rev = "v${version}";
    sha256 = "1giyp2xk2rb6vdyfnj5wa7qb9fwbcmmwm16wdlnmq7xnp7qamdkw";
    fetchSubmodules = true;
  };
in buildGoPackage  rec {
  name = "micro-${version}";
  inherit version;

  goPackagePath = "github.com/zyedidia/micro";

  src = fetchFromGitHub srcinfo;

  subPackages = [ "cmd/micro" ];

  buildFlagsArray = [ "-ldflags=" "-X main.Version=${version}" ];

  passthru.updateScript = latestGitHubRelease "micro" srcinfo;

  meta = with stdenv.lib; {
    homepage = https://micro-editor.github.io;
    description = "Modern and intuitive terminal-based text editor";
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
  };
}

