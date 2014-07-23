{ stdenv, fetchurl, zlib, gd, texinfo, makeWrapper, readline
, texLive ? null
, lua ? null
, emacs ? null
, libX11 ? null
, libXt ? null
, libXpm ? null
, libXaw ? null
, aquaterm ? false
, wxGTK ? null
, pango ? null
, cairo ? null
, pkgconfig ? null
, fontconfig ? null
, gnused ? null
, coreutils ? null
, qt ? null }:

assert libX11 != null -> (fontconfig != null && gnused != null && coreutils != null);
let
  withX = libX11 != null && !aquaterm;
  withQt = qt != null;
in
stdenv.mkDerivation rec {
  name = "gnuplot-4.6.3";

  src = fetchurl {
    url = "mirror://sourceforge/gnuplot/${name}.tar.gz";
    sha256 = "1xd7gqdhlk7k1p9yyqf9vkk811nadc7m4si0q3nb6cpv4pxglpyz";
  };

  buildInputs =
    [ zlib gd texinfo readline emacs lua texLive
      pango cairo pkgconfig makeWrapper ]
    ++ stdenv.lib.optionals withX              [ libX11 libXpm libXt libXaw ]
    ++ stdenv.lib.optional withQt [ qt ]
    # compiling with wxGTK causes a malloc (double free) error on darwin
    ++ stdenv.lib.optional (!stdenv.isDarwin) wxGTK;

  configureFlags =
    (if withX then ["--with-x"] else ["--without-x"])
    ++ (if withQt then ["--enable-qt"] else ["--disable-qt"])
    ++ (if aquaterm then ["--with-aquaterm"] else ["--without-aquaterm"])
    ;

  postInstall = stdenv.lib.optionalString withX ''
    wrapProgram $out/bin/gnuplot \
       --prefix PATH : '${gnused}/bin' \
       --prefix PATH : '${coreutils}/bin' \
       --prefix PATH : '${fontconfig}/bin' \
       --run '. ${./set-gdfontpath-from-fontconfig.sh}'
  '';

  meta = with stdenv.lib; {
    homepage    = http://www.gnuplot.info;
    description = "A portable command-line driven graphing utility for many platforms";
    hydraPlatforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ lovek323 ];
  };
}
