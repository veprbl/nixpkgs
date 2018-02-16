{ stdenv
, julia
, pkgs
}:

self:
super:
{

  "Compat" = self.buildJuliaPackage rec {
    pname = "Compat";
    version = "0.53.0";

    src = pkgs.fetchFromGitHub {
      owner = "JuliaLang";
      repo = "${pname}.jl";
      rev = "v${version}";
      sha256 = "1x96h6kbfk4zvx1wacn6cihhkm6ms2yglhhs6liwdii9kb7cmh8z";
    };
  };

  "MetadataTools" = self.buildJuliaPackage rec {
    pname = "MetadataTools";
    version = "0.4.0";

    src = pkgs.fetchFromGitHub {
      owner = "JuliaPackaging";
      repo = "${pname}.jl";
      rev = "v${version}";
      sha256 = "16r8p9qhx97bdq7gzg8kd9qhbzcb23i8piiwdkq2m3l8vrmc3wfx";
    };
  };

  "Nullables" = self.buildJuliaPackage rec {
    pname = "Nullables";
    version = "0.0.3";

    src = pkgs.fetchFromGitHub {
      owner = "JuliaArchive";
      repo = "${pname}.jl";
      rev = "v${version}";
      sha256 = "1h03h7f3zh707kvs399xvqyy0w8qhajl3g9slc4215bsijg4xb6y";
    };
  };

  "JSON" = self.buildJuliaPackage rec {
    pname = "JSON";
    version = "0.16.4";

    src = pkgs.fetchFromGitHub {
      owner = "JuliaIO";
      repo = "${pname}.jl";
      rev = "v${version}";
      sha256 = "0mlw8lkf1n27vjhfp91an24b9hpd7rc05la6l8d541hjv6ajijs4";
    };
  };
}
