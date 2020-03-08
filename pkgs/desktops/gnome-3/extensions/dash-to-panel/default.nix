{ stdenv, fetchFromGitHub, glib, gettext }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-dash-to-panel";
  version = "29";

  src = fetchFromGitHub {
    owner = "home-sweet-gnome";
    repo = "dash-to-panel";
    rev = "v${version}";
    sha256 = "1a92q8yg4pdsn2f6qvn00lcxxm7l8sd67ii44kbbzbhkfa351l62";
  };

  buildInputs = [
    glib gettext
  ];

  makeFlags = [ "INSTALLBASE=$(out)/share/gnome-shell/extensions" ];

  meta = with stdenv.lib; {
    description = "An icon taskbar for Gnome Shell";
    license = licenses.gpl2;
    maintainers = with maintainers; [ mounium ];
    homepage = "https://github.com/jderose9/dash-to-panel";
  };
}
