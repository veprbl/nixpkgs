{ otfcc, fetchFromGitHub }:

otfcc.overrideAttrs (o: rec {
  name = "otfcc-${version}";
  version = "0.10.3-alpha";

  src = fetchFromGitHub {
    owner = "caryll";
    repo = "otfcc";
    rev = "v${version}";
    sha256 = "0lr9g64k0clfkzy3gj90v618bq1xm2xy1xw4ml1c9w48wkhnx473";
  };
})
