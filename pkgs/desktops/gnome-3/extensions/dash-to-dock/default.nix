{ stdenv, fetchFromGitHub, glib, gettext }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-dash-to-dock-unstable";
  version = "20200313";

  src = fetchFromGitHub {
    owner = "micheleg";
    repo = "dash-to-dock";
    # rev = "extensions.gnome.org-v" + version;
    rev = "800dc0abd65323f158b33a6c883329c036bb7bcb";
    sha256 = "1a92q8yg4pdsn2f6qvn00lcxxm7l8sd67ii44kbbzbhkfa351l62";
  };

  nativeBuildInputs = [
    glib gettext
  ];

  makeFlags = [ "INSTALLBASE=$(out)/share/gnome-shell/extensions" ];

  meta = with stdenv.lib; {
    description = "A dock for the Gnome Shell";
    license = licenses.gpl2;
    maintainers = with maintainers; [ eperuffo ];
    homepage = https://micheleg.github.io/dash-to-dock/;
  };
}
