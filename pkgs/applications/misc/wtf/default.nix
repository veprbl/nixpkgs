{ buildGoModule
, fetchFromGitHub
, lib
}:

buildGoModule rec {
  pname = "wtf";
  version = "0.8.0";

  goPackagePath = "github.com/wtfutil/wtf";

  src = fetchFromGitHub {
    owner = "wtfutil";
    repo = pname;
    rev = version;
    sha256 = "1m1nwwsnx6ylw2l50vp5c4fg0l2m8ash6w5hmniwmic4w6gv30vm";
  };

  patches = [ ./fix-hash.patch ];

  buildFlagsArray = '' -ldflags= -X main.version=${version} '';

  modSha256 = "00bhhx6mpamqx5xkhphx5hplaca53srmnv2r4ykiagzhdsbxk2g1";

  meta = with lib; {
    description = "The personal information dashboard for your terminal";
    homepage = http://wtfutil.com/;
    license = licenses.mpl20;
    maintainers = with maintainers; [ kalbasit ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
