{ stdenv, buildGoPackage, fetchFromGitHubWithUpdater, makeWrapper, git }:


buildGoPackage rec {
  name = "fac-${version}";
  version = "1.0.4";

  goPackagePath = "github.com/mkchoi212/fac";

  src = fetchFromGitHubWithUpdater {
    owner = "mkchoi212";
    repo = "fac";
    rev = "v${version}";
    sha256 = "0jhx80jbkxfxj95hmdpb9wwwya064xpfkaa218l1lwm3qwfbpk95";
  };
  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $bin/bin/fac \
      --prefix PATH : ${git}/bin
  '';

  passthru.updateScript = src.updateScript;

  meta = with stdenv.lib; {
    description = "CUI for fixing git conflicts";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
  };
}

