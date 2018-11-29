{ stdenv, fetchFromGitHub, bash, which, withFont ? "" }:

stdenv.mkDerivation rec {
  #version = "2.0.0";
  version = "2018-11-25";
  name = "nerdfonts-${version}";
  src = fetchFromGitHub {
    owner = "ryanoasis";
    repo = "nerd-fonts";
    #rev = version;
    rev = "e9ec3ae4548e59eb9a6531f38370cb99ca591e16";
    sha256 = "0g99rmwl7ibdpxcxnnqkc9fj4ibkv63azdcs0hahaysh4azapzsa";
  };
  nativeBuildInputs = [ bash which ];
  patchPhase = ''
    patchShebangs install.sh
    sed -i -e 's|font_dir="\$HOME/.local/share/fonts|font_dir="$out/share/fonts/truetype|g' install.sh
  '';
  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    ./install.sh ${withFont}
  '';

  meta = with stdenv.lib; {
    description = ''
      Nerd Fonts is a project that attempts to patch as many developer targeted
      and/or used fonts as possible. The patch is to specifically add a high
      number of additional glyphs from popular 'iconic fonts' such as Font
      Awesome, Devicons, Octicons, and others.
    '';
    homepage = https://github.com/ryanoasis/nerd-fonts;
    license = licenses.mit;
    maintainers = with maintainers; [ garbas ];
    platforms = with platforms; unix;
    hydraPlatforms = []; # 'Output limit exceeded' on Hydra
  };
}
