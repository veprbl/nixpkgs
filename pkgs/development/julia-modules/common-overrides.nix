{ stdenv
, julia
, pkgs
}:

self:
super:
{

  "Compat" = self.buildJuliaPackage rec {
    pname = "Compat";
    version = "0.24.0";

    src = pkgs.fetchFromGitHub {
      owner = "JuliaLang";
      repo = "${pname}.jl";
      rev = "v${version}";
      sha256 = "1jnfvy137175v5ryp5hwd6dvm3vl98rw72gzdyvki1bb43wiv794";
    };
  };


}
