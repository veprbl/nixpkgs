{ stdenv, fetchgit, cmake, python }:

stdenv.mkDerivation {
  name = "ycm_core-999";
  
  src = fetchgit {
    url = "https://github.com/Valloric/YouCompleteMe.git";
    rev = "913627419096d66a1e73da146e981b527f939eff";
    sha256 = "0s7if6wagfxgzs4dsczmc0k7nfwzw9zswxsa5j0gpi6l3xq2ii3y";
  };

  buildInputs = [ 
    cmake python 
  ];

  installPhase = ''
    mkdir -p $out/lib
    cp ../python/ycm_core.so $out/lib
  '';

  cmakeFlags = "../cpp";
  
  meta = {
    homepage = http://valloric.github.io/YouCompleteMe/;
    description = "A code-completion engine for Vim core";
  };
}
