{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "libertinus-${version}";
  version = "6.8";

  src = fetchFromGitHub {
    rev    = "v${version}";
    owner  = "libertinus-fonts";
    repo   = "libertinus";
    sha256 = "1sz0mfi0s8wxbaxlqrlv6szj07mdgizsb6qi4l4xjvxxahs7dc4v";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/fonts/opentype/
    mkdir -p $out/share/doc/${name}/
    cp *.otf $out/share/fonts/opentype/
    cp *.txt $out/share/doc/${name}/
  '';

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "0iwbw3sw8rcsifpzw72g3cz0a960scv7cib8mwrw53282waqq2gc";

  meta = with stdenv.lib; {
    description = "A fork of the Linux Libertine and Linux Biolinum fonts";
    longDescription = ''
      Libertinus fonts is a fork of the Linux Libertine and Linux Biolinum fonts
      that started as an OpenType math companion of the Libertine font family,
      but grown as a full fork to address some of the bugs in the fonts.
    '';
    homepage = https://github.com/libertinus-fonts/libertinus;
    license = licenses.ofl;
    maintainers = with maintainers; [ siddharthist ];
    platforms = platforms.all;
  };
}
