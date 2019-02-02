{ stdenv, fetchFromGitHub, pantheon, meson, python3,ninja, hicolor-icon-theme, gtk3 }:

stdenv.mkDerivation rec {
  pname = "elementary-icon-theme";
  #version = "5.0.2";
  version = "5.0.2.0.1"; # not really
  repoName = "icons";


  src = fetchFromGitHub {
    owner = "elementary";
    repo = repoName;
    #rev = version;
    rev = "d9fe8bc75be4e365cd3832fb0b7eebb2a43a6436";
    sha256 = "0yv71avpa7q3sr6613ga1pqhilcc0w9j18r83njns65r1v3d1hb0";
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
