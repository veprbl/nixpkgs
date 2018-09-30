{ stdenv, fetchFromGitHub, sassc, autoreconfHook, pkgconfig, gtk3
, gnome-themes-extra, gtk-engine-murrine, optipng, inkscape, which }:

let
  pname = "arc-theme";
in

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  version = "20180929";

  src = fetchFromGitHub {
    owner  = "NicoHood";
    repo   = pname;
    rev    = "86e43a874cf4a2f1e5855f147818ffc6786aeff5";
    sha256 = "18qna7y0cycp41p2cmmisjgg39ls6ral3ylb7bsq1hd19gifaysk";
  };

  preBuild = ''
    # Shut up inkscape's warnings
    export HOME="$NIX_BUILD_ROOT"
  '';

  nativeBuildInputs = [ autoreconfHook pkgconfig sassc optipng inkscape which ];
  buildInputs = [ gtk3 ];

  propagatedUserEnvPkgs = [ gnome-themes-extra gtk-engine-murrine ];

  postPatch = ''
    find . -name render-assets.sh |
    while read filename
    do
      substituteInPlace "$filename" \
        --replace "/usr/bin/inkscape" "${inkscape.out}/bin/inkscape" \
        --replace "/usr/bin/optipng" "${optipng.out}/bin/optipng"
    done
    patchShebangs .
  '';

  configureFlags = [ "--disable-unity" "--disable-gnome-shell" /* XXX: enable once avail! */ ];

  postInstall = ''
    install -Dm644 -t $out/share/doc/${pname}        AUTHORS *.md
  '';

  meta = with stdenv.lib; {
    description = "A flat theme with transparent elements for GTK 3, GTK 2 and Gnome-Shell";
    homepage    = https://github.com/NicoHood/arc-theme;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ simonvandel romildo ];
    platforms   = platforms.linux;
  };
}
