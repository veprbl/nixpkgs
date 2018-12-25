{ stdenv, fetchzip }:

let
  version = "1.32b-3";
in stdenv.mkDerivation {
  name = "ioquake3-patch-data-${version}";

  src = fetchzip {
    url = "https://www.ioquake3.org/data/quake3-latest-pk3s.zip";
    sha256 = "0da9xgdlfnm7b03bcmbblg94fxaagsngg4if6fpvqg3qb1wlmg8z";
  };

  buildCommand = ''
    mkdir -p $out/baseq3 $out/missionpack

    cp baseq3/*.pk3 $out/baseq3
    cp missionpack/*.pk3 $out/missionpack
  '';

  preferLocalBuild = true;

  meta = with stdenv.lib; {
    description = "Quake 3 Arena point release from ioquake3";
    license = licenses.unfreeRedistributable;
    platforms = platforms.all;
    maintainers = with maintainers; [ rvolosatovs ];
  };
}
