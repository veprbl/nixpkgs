{ buildGoPackage
, fetchFromGitHub
, lib
}:

buildGoPackage rec {
  pname = "wtf";
  version = "0.5.0";

  goPackagePath = "github.com/wtfutil/wtf";

  src = fetchFromGitHub {
    owner = "wtfutil";
    repo = "wtf";
    rev = "${version}";
    sha256 = "1f59ck6rqicswjp6l5x35n0aqdicjc7jkwlpsyy477gisdlbw058";
  };

  buildFlagsArray = [ "-ldflags=" "-X main.version=${version}" ];

  goDeps = ./deps.nix;

  meta = with lib; {
    description = "The personal information dashboard for your terminal";
    homepage = http://wtfutil.com/;
    license = licenses.mpl20;
    maintainers = with maintainers; [ kalbasit ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
