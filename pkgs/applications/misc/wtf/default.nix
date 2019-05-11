{ buildGoModule
, fetchFromGitHub
, lib
}:

buildGoModule rec {
  pname = "wtf";
  version = "0.9.1";

  goPackagePath = "github.com/wtfutil/wtf";

  src = fetchFromGitHub {
    owner = "wtfutil";
    repo = pname;
    rev = version;
    sha256 = "0l8chb6cjxida1pxz7qyajn4axlbmzkq2jy9awma0hjg8ak9ybjh";
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
