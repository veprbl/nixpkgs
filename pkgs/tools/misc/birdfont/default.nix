{ stdenv, fetchurl, xmlbird, libgee, glib, gtk3, webkitgtk, libnotify, sqlite }:

stdenv.mkDerivation rec {
  pname = "birdfont";
  version = "2.25.0";

  src = fetchurl {
    url = "https://birdfont.org/releases/${pname}-${version}.tar.xz";
    sha256 = "0fi86km9iaxs9b8lqz81079vppzp346kqiqk44vk45dclr5r6x22";
  };
  
  buildInputs = [ xmlbird libgee glib gtk3 webkitgtk libnotify sqlite ];
}
