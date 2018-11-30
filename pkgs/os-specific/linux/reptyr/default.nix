{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  version = "0.6.2-git";
  name = "reptyr-${version}";
  src = fetchFromGitHub {
    owner = "nelhage";
    repo = "reptyr";
    #rev = "reptyr-${version}";
    rev = "40aad4c914eebcfa5d8a310da4165b8652bf6eee";
    sha256 = "16wv8x9kn6c0gmclmwq737v3wxjwxjnrysiap41yidis0dbdz31n";
  };

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "BASHCOMPDIR=${placeholder "out"}/share/bash-completion/completions"
  ];

  meta = {
    platforms = [ "i686-linux" "x86_64-linux" ];
    maintainers = with stdenv.lib.maintainers; [raskin];
    license = stdenv.lib.licenses.mit;
    description = ''A Linux tool to change controlling pty of a process'';
  };
}
