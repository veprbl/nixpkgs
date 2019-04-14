{ buildGoPackage
, fetchFromGitHub
, lib
}:

buildGoPackage rec {
  pname = "wtf";
  version = "0.6.0";

  goPackagePath = "github.com/wtfutil/wtf";

  src = fetchFromGitHub {
    owner = "wtfutil";
    repo = "wtf";
    rev = version;
    sha256 = "1662b63xy63fi96xn5c622ppmwn4lzlhmx2w57wyhvh8dpsrzkl6";
  };

  buildFlagsArray = let
    # this is easy when version is a date already :)
    release-datetime = version + "T00:00:00+0000";
  in ''
    -ldflags=
    -X main.version=${version}
    -X main.date=${release-datetime}
  '';

  goDeps = ./deps.nix;

  meta = with lib; {
    description = "The personal information dashboard for your terminal";
    homepage = http://wtfutil.com/;
    license = licenses.mpl20;
    maintainers = with maintainers; [ kalbasit ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
