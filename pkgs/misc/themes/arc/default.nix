{ stdenv, fetchFromGitHub, sassc, autoreconfHook, pkgconfig, gtk3, gnome3
, gtk-engine-murrine, optipng, inkscape }:

let
  pname = "arc-theme";
in

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  version = "20181223";

  src = fetchFromGitHub {
    owner  = "NicoHood";
    repo   = pname;
    rev    = "b96ab0aba7e8234ecb62447047371f727ffcc599";
    sha256 = "16dzq70jynqrbnz9n8clz9gapm4zgw1g3ybgqndykm0ngzz42gvb";
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
