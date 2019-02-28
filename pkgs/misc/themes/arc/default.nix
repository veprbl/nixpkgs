{ stdenv, fetchFromGitHub, sassc, autoreconfHook, pkgconfig, gtk3, gnome3
, gtk-engine-murrine, optipng, inkscape }:

stdenv.mkDerivation rec {
  pname = "arc-theme";
  version = "20190227";

  src = fetchFromGitHub {
    owner  = "NicoHood";
    repo   = pname;
    #rev    = version;
    rev = "4802bc1fb9270b4e830ccf8361703f4ff698cff4";
    sha256 = "070xxfslw4dhvhn51x216mc7rd3fg6k2p8zvsjhnrappsc6vax6d";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkgconfig
    sassc
    optipng
    inkscape
    gtk3
    gnome3.gnome-shell
  ];

  propagatedUserEnvPkgs = [
    gnome3.gnome-themes-extra
    gtk-engine-murrine
  ];

  enableParallelBuilding = true;

  postPatch = ''
    patchShebangs .
  '';

  preBuild = ''
    # Shut up inkscape's warnings about creating profile directory
    export HOME="$NIX_BUILD_ROOT"
  '';

  configureFlags = [ "--disable-unity" ];

  postInstall = ''
    install -Dm644 -t $out/share/doc/${pname} AUTHORS *.md
  '';

  meta = with stdenv.lib; {
    description = "A flat theme with transparent elements for GTK 3, GTK 2 and Gnome-Shell";
    homepage    = https://github.com/NicoHood/arc-theme;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ simonvandel romildo ];
    platforms   = platforms.linux;
  };
}
