{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "lab-${version}";
  version = "0.15.2";

  src = fetchFromGitHub {
    owner = "zaquestion";
    repo = "lab";
    rev = "v${version}";
    sha256 = "1210cf6ss4ivm2jxq3k3c34vpra02pl91fpmvqbvw5sm53j7xfaf";
  };

  subPackages = [ "." ];

  modSha256 = "0bw47dd1b46ywsian2b957a4ipm77ncidipzri9ra39paqlv7abb";

  postInstall = ''
    mkdir -p $out/share/zsh/site-functions
    LAB_CORE_HOST=a LAB_CORE_USER=b LAB_CORE_TOKEN=c \
    $out/bin/lab completion zsh > $out/share/zsh/site-functions/_lab
  '';

  meta = with stdenv.lib; {
    description = "Lab wraps Git or Hub, making it simple to clone, fork, and interact with repositories on GitLab";
    homepage = https://zaquestion.github.io/lab;
    license = licenses.unlicense;
    maintainers = [ maintainers.marsam ];
    platforms = platforms.all;
  };
}
