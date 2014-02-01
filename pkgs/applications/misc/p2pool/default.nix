{ stdenv, fetchurl, buildPythonPackage, pythonPackages }:

let
    version = "13.3";

    src = fetchurl {
      url = "https://github.com/forrestv/p2pool/archive/${version}.tar.gz";
      sha256 = "0hy33vrgbzlafqwgf12ygs8wr6ngfw507y95zdpkgxlssj66661c";
    };

    p2pool_scrypt = buildPythonPackage {
        name = "p2pool_scrypt-${version}";
        inherit src;
        sourceRoot = "p2pool-${version}/litecoin_scrypt";
        doCheck = false;
    };
in buildPythonPackage {
    name = "p2pool-${version}";

    inherit src;

    postPatch = ''
      cp ${./setup.py} setup.py
    '';

    doCheck = false;

    propagatedBuildInputs = with pythonPackages; [ zope_interface twisted argparse nattraverso p2pool_scrypt ];

    meta = {
      description = "Image viewer designed to handle comic books";

      longDescription = ''
        MComix is an user-friendly, customizable image viewer. It is specifically
        designed to handle comic books, but also serves as a generic viewer.
        It reads images in ZIP, RAR, 7Zip or tar archives as well as plain image
        files. It is written in Python and uses GTK+ through the PyGTK bindings,
        and runs on both Linux and Windows.

        MComix is a fork of the Comix project, and aims to add bug fixes and
        stability improvements after Comix development came to a halt in late 2009.
      '';

      homepage = http://mcomix.sourceforge.net/;

      license = "GPLv2";
    };
}
