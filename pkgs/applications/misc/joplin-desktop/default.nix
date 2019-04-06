{ appimageTools, fetchurl, lib, pkgs }:

let
  version = "1.0.142";
  sha256 = "0k7lnv3qqz17a2a2d431sic3ggi3373r5k0kwxm4017ama7d72m1";
  pname = "joplin";
in appimageTools.wrapType2 rec {
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/laurent22/joplin/releases/download/v${version}/Joplin-${version}-x86_64.AppImage";
    inherit sha256;
  };

  extraPkgs = p: with p; [ gnome3.dconf gtk3 librsvg gsettings-desktop-schemas ];

  profile = ''
   export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:$XDG_DATA_DIRS"
   env
  '';

  meta = with lib; {
    description = "An open source note taking and to-do application with synchronisation capabilities";
    longDescription = ''
      Joplin is a free, open source note taking and to-do application, which can
      handle a large number of notes organised into notebooks. The notes are
      searchable, can be copied, tagged and modified either from the
      applications directly or from your own text editor. The notes are in
      Markdown format.
    '';
    homepage = https://joplin.cozic.net/;
    license = licenses.mit;
    maintainers = with maintainers; [ rafaelgg raquelgb ];
    platforms = [ "x86_64-linux" ];
  };
}
