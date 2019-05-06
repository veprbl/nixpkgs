{ stdenv, fetchFromGitHub, lua }:

stdenv.mkDerivation rec {
  pname = "z-lua";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "skywind3000";
    repo = "z.lua";
    rev = "v${version}";
    sha256 = "1f8iafv81xsypa78prazq6k2xz8az09kjhl97vn330drxkcpj7i7";
  };

  # May not be desirable for everyone
  patches = [
    ./0001-escape-patterns-fix-hyphen-behavior-but-lose-lua-reg.patch
    ./0002-escape-just-hyphens-as-quickfix-compromise.patch
  ];

  dontBuild = true;

  buildInputs = [ lua ];

  installPhase = ''
    install -Dm755 z.lua $out/bin/z
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/skywind3000/z.lua;
    description = "A new cd command that helps you navigate faster by learning your habits";
    license = licenses.mit;
    maintainers = [ maintainers.marsam ];
  };
}
