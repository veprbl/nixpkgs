{ stdenv, fetchgit
, meson, ninja, pkgconfig
, gtk3, lightdm, dbus-glib, webkitgtk }:

stdenv.mkDerivation rec {
  version = "2.2.5";
  name = "lightdm-webkit2-greeter-${version}";

  src = fetchgit {
    url = https://github.com/Antergos/web-greeter;
    rev = version;
    sha256 = "109qvybpwb35sybga7vfhr67w7w15zlx1d2nrhikmhj1miayr3id";
  };

  postPatch = ''
    patchShebangs .
    sed -i "s@/etc\|/usr@$out@g" meson_options.txt
  '';

  buildInputs = [
    gtk3
    meson
    ninja
    lightdm
    dbus-glib
    webkitgtk
  ];

  nativeBuildInputs = [
    pkgconfig
  ];

  meta = with stdenv.lib; {
    homepage = http://antergos.github.io/web-greeter/;
    platforms = platforms.linux;
    license = licenses.gpl3;
    maintainers = with maintainers; [
      eadwu
    ];
  };
}
