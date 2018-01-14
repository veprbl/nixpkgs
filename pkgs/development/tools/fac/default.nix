{ stdenv, buildGoPackage, fetchFromGitHub, makeWrapper, git, latestGitHubRelease }:

let
  version = "1.0.4";
  srcinfo = {
    owner = "mkchoi212";
    repo = "fac";
    rev = "v${version}";
    sha256 = "0jhx80jbkxfxj95hmdpb9wwwya064xpfkaa218l1lwm3qwfbpk95";
  };

in buildGoPackage rec {
  name = "fac-${version}";
  inherit version;

  goPackagePath = "github.com/mkchoi212/fac";

  src = fetchFromGitHub srcinfo;
  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $bin/bin/fac \
      --prefix PATH : ${git}/bin
  '';

  passthru.updateScript = latestGitHubRelease "fac" srcinfo;

  meta = with stdenv.lib; {
    description = "CUI for fixing git conflicts";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
  };
}

