{ stdenv, fetchFromGitHub
# runtime deps, adhoc
, git, python3, ruby, runtimeShell }:


let
  path = stdenv.lib.makeBinPath [ git python3 ruby runtimeShell ];
in stdenv.mkDerivation rec {
  pname = "git-extra-commands";
  version = "2019-03-11";

  src = fetchFromGitHub {
    owner = "unixorn";
    repo = pname;
    rev = "865e60d5f6a8c6d952c71a465f8d2e991cd3c469";
    sha256 = "181wip7fnsg57qypndxjvhx5zf3cfalcqjf8k03x5zwvaqmda997";
  };

  dontBuild = true;

  installPhase = ''
    install -Dm644 ${pname}.plugin.zsh $out/share/zsh/plugins/${pname}/${pname}.plugin.zsh

    mv bin $out/bin

    PATH=${path}:$PATH patchShebangs $out/bin
    for x in $out/bin/*; do
      wrapProgram $x --prefix PATH : ${path}
    done
  '';
}

