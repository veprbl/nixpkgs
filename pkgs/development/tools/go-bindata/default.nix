{ stdenv, lib, buildGoPackage, fetchFromGitHub, fetchhg, fetchbzr, fetchsvn }:

buildGoPackage rec {
  name = "go-bindata-${version}";
  version = "3.0.5";
  rev = "a0ff2567cfb70903282db057e799fd826784d41d";
  
  goPackagePath = "github.com/jteeuwen/go-bindata";

  src = fetchFromGitHub {
    owner = "jteeuwen";
    repo = "go-bindata";
    rev = "v${version}";
    sha256 = "1axjrhrsc1a7bkk7rynmhigm6xhqbjml6shwfhmf4b332saiyk11";
  };

  excludedPackages = "testdata";

  meta = with stdenv.lib; {
    homepage    = "https://github.com/jteeuwen/go-bindata";
    description = "A small utility which generates Go code from any file, useful for embedding binary data in a Go program";
    maintainers = with maintainers; [ cstrahan ];
    license     = licenses.cc0 ;
    platforms   = platforms.all;
  };
}
