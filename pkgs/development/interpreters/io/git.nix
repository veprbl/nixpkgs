{ io, fetchFromGitHub }:

io.overrideAttrs (o: rec {
  name = "io-${version}";
  version = "2018.09.22";
  src = fetchFromGitHub {
    owner = "stevedekorte";
    repo = "io";
    rev = "67dbe416568215d544582ba8f7f6bb6ee8922f7a";
    sha256 = "10vagwfsf5prgdgicxb1nz8aavc4zclq3n6dizwlbps79xj0j3gb";
    fetchSubmodules = true;
  };
})
