{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "openzone-cursors-${version}";
  version = "1.2.6";

  src = fetchurl {
    url = "https://dl.opendesktop.org/api/files/downloadfile/id/1514377984/s/721213e16ff79a17d0cbeb10d8beabe8/t/1534237528/u/OpenZone-1.2.6.tar.xz";
    sha256 = "0d9rbycxmwyyhwrz5k8ysfya2481z8p4qbc0jgh35p0akykl30xd";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/icons
    for archive in *.tar.xz; do
      tar Jxf "$archive"
      cp -R "$(echo "$archive" | cut -d'-' -f1)" $out/share/icons/
    done
  '';

  meta = with stdenv.lib; {
    description = "OpenZone cursor theme";
    homepage = https://www.opendesktop.org/p/999999/;
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ mnacamura ];
  };
}
