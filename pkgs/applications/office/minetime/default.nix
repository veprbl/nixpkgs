{ appimageTools, fetchurl }:

let
  pname = "MineTime";
  version = "1.4.10";
in
appimageTools.wrapType2 rec {
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/marcoancona/MineTime/releases/download/v${version}/${name}-x86_64.AppImage";
    sha256 = "11w1v9vlg51masxgigraqp5547dl02jrrwhzz5gcckv4l9y8rlyw";
  };

  extraPkgs = p: [ 
    p.gnome3.gnome-keyring
    p.gnome3.seahorse
    p.gnome3.libsecret
    p.at-spi2-core
    p.dbus
    p.gnome3.gnome-online-accounts
    p.libgpgerror
    p.desktop-file-utils
    p.appstream-glib
    p.gnome3.gsettings-desktop-schemas

    p.libnotify
  ];

  # our glibc doesn't actually support this yet,
  # but even so this fixes account creation.
  profile = ''
    export LC_ALL=C.UTF8
  '';

  # TODO: meta!
}
