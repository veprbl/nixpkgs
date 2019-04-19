{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  # https://github.com/erroneousboat/slack-term
  name = "slack-term-${version}";
  version = "0.4.1-git";

  goPackagePath = "github.com/erroneousboat/slack-term";

  src = fetchFromGitHub {
    owner = "erroneousboat";
    repo = "slack-term";
    #rev = "v${version}";
    rev = "112524daad6315323d6097222d3b2759ed353aaf";
    sha256 = "18nk3dxm7laknncwkdgc6y7aiya2vwhs8c2xvchp6ln01nnf99z2";
  };

  meta = with stdenv.lib; {
    description = "Slack client for your terminal";
    homepage = https://github.com/erroneousboat/slack-term;
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
  };
}
