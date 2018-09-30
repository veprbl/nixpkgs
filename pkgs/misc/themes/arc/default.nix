{ stdenv, fetchFromGitHub, sassc, autoreconfHook, pkgconfig, gtk3
, gnome-themes-extra, gtk-engine-murrine, optipng, inkscape, which }:

let
  pname = "arc-theme";
in

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  version = "20181001";

  src = fetchFromGitHub {
    owner  = "NicoHood";
    repo   = pname;
    rev    = "7a719566dbbc46fba388429eb57236d0e9b873d2";
    sha256 = "1nmh445v936x6a3gqqg18db6yyy5lf97zpc5v9izvdzni2nnj309";
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
