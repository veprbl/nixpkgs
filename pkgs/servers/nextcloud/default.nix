{ stdenv, fetchzip }:
let
  version = "16.0.1RC1";
in fetchzip {
  name = "nextcloud-${version}";

  url = "https://download.nextcloud.com/server/prereleases/nextcloud-${version}.tar.bz2";
  sha256 = "0pqf3czn8dgw6nchbvrpp8pcyhphqkdan7470qsz7zz75dq4vgcv";

  meta = {
    description = "Sharing solution for files, calendars, contacts and more";
    homepage = https://nextcloud.com;
    maintainers = with stdenv.lib.maintainers; [ schneefux bachp globin fpletz ];
    license = stdenv.lib.licenses.agpl3Plus;
    platforms = with stdenv.lib.platforms; unix;
  };
}
