{ stdenv, fetchFromGitHub, pantheon, meson, python3,ninja, hicolor-icon-theme, gtk3 }:

stdenv.mkDerivation rec {
  pname = "elementary-icon-theme";
  version = "5.0.3";
  repoName = "icons";


  src = fetchFromGitHub {
    owner = "elementary";
    repo = repoName;
    #rev = version;
    rev = version;
    sha256 = "0wpv7yirf44bfqfmyshzfw9605j1idm7c9jqg68k3nmymmd6iqzf";
  };

  passthru = {
    updateScript = pantheon.updateScript {
      repoName = repoName;
      attrPath = pname;
    };
  };

  nativeBuildInputs = [
    meson
    ninja
    python3
  ];

  buildInputs = [ gtk3 ];

  propagatedBuildInputs = [ hicolor-icon-theme ];

  mesonFlags = [
    "-Dvolume_icons=false" # Tries to install some icons to /
    "-Dpalettes=false" # Don't install gimp and inkscape palette files
  ];

  postPatch = ''
    chmod +x meson/symlink.py
    patchShebangs meson/symlink.py
  '';

  postFixup = "gtk-update-icon-cache $out/share/icons/elementary";

  meta = with stdenv.lib; {
    description = "Named, vector icons for elementary OS";
    longDescription = ''
      An original set of vector icons designed specifically for elementary OS and its desktop environment: Pantheon.
    '';
    homepage = https://github.com/elementary/icons;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = pantheon.maintainers;
  };
}
