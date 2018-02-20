{ stdenv
, julia
, pkgs
}:

self:
super:
{
  pinnedPackages = {
    Compat = { version = "0.53.0"; };
  };
}
