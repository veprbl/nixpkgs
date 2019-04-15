{ stdenv, fetchFromGitHub, qmake, qtbase, qtsvg, qtx11extras, kwindowsystem, libX11, libXext, qttools }:

stdenv.mkDerivation rec {
  pname = "qtstyleplugin-kvantum";
  #version = "0.11.0";

  src = fetchFromGitHub {
    owner = "tsujan";
    repo = "Kvantum";
    #rev = "V${version}";
    rev = "3d452d5ca671ee64a9a054397966ac4fa5daea7b";
    sha256 = "1pycbk5dmj6vhnwvm87csmir4crqk4g4z05402xw5ia9k1clpksk";
  };

  nativeBuildInputs = [ qmake qttools ];
  buildInputs = [ qtbase qtsvg qtx11extras kwindowsystem libX11 libXext  ];

  sourceRoot = "source/Kvantum";

  postPatch = ''
    # Fix plugin dir
    substituteInPlace style/style.pro \
      --replace "\$\$[QT_INSTALL_PLUGINS]" "$out/$qtPluginPrefix"
  '';

  meta = with stdenv.lib; {
    description = "SVG-based Qt5 theme engine plus a config tool and extra themes";
    homepage = "https://github.com/tsujan/Kvantum";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ maintainers.bugworm ];
  };
}
