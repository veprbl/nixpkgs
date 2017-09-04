{ stdenv, buildGoPackage, fetchFromGitHub, git, perl, makeWrapper }:

with stdenv.lib;

buildGoPackage rec {
  name = "git-octopus-${version}";
  version = "2.0beta.3";

  goPackagePath = "github.com/lesfurets/git-octopus";

  buildInputs = [ makeWrapper ];

  # perl provides shasum
  postInstall = ''
    for f in $out/bin/*; do
      wrapProgram $f --prefix PATH : ${makeBinPath [ git perl ]}
    done
  '';

  src = fetchFromGitHub {
    owner = "lesfurets";
    repo = "git-octopus";
    rev = "v2.0-beta.3";
    sha256 = "1hjmq2yyxagfx6dvycs31mwpg3f2nhy0ygxbzckcypc3dsvskzvm";
  };

  meta = {
    homepage = https://github.com/lesfurets/git-octopus;
    description = "The continuous merge workflow";
    license = licenses.lgpl3;
    platforms = platforms.unix;
    maintainers = [maintainers.mic92];
  };
}
