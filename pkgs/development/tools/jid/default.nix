{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "jid";
  version = "0.7.5";

  src = fetchFromGitHub {
    owner = "simeji";
    repo = "jid";
    rev = "v${version}";
    sha256 = "15gji50mgjg1s00xvh2jv9j50x3431k4mv3d3i153py2vyyi0h08";
  };

  modSha256 = "10n452hk5kg449vm0iv264gj47zsyikwiiirkzfj05dla69l76xd";

  meta = {
    description = "A command-line tool to incrementally drill down JSON";
    homepage = https://github.com/simeji/jid;
    license = stdenv.lib.licenses.mit;
    platforms = stdenv.lib.platforms.all;
    maintainers = with stdenv.lib.maintainers; [ stesie ];
  };
}
