{ buildGoPackage
, fetchFromGitHub
, lib
}:

buildGoPackage rec {
  pname = "wtf";
  #version = "0.5.0";
  version = "2019-03-07";

  goPackagePath = "github.com/wtfutil/wtf";

  src = fetchFromGitHub {
    owner = "wtfutil";
    repo = "wtf";
    #rev = "${version}";
    rev = "66e5e9a3d002875103843372e020937491d97287";
    sha256 = "1iqminmr86aifcpbk1ll1q0vg15mqiyp8b35p6iqf3mn68l1h59w";
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
