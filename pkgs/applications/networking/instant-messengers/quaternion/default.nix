{ stdenv, lib, fetchFromGitHub, fetchpatch, cmake
, qtbase, qtquickcontrols, qtkeychain, qtmultimedia, qttools
, libqmatrixclient_0_4, libqmatrixclient_0_5 }:

let
  generic = version: sha256: prefix: library: stdenv.mkDerivation rec {
    name = "quaternion-${version}";

    src = fetchFromGitHub {
      owner = "QMatrixClient";
      repo  = "Quaternion";
      rev   = "${prefix}${version}";
      inherit sha256;
    };

    patches = [
      ./usercolors.patch
      # color users
      #(fetchpatch {
      #  url = https://github.com/QMatrixClient/Quaternion/pull/528.patch;
      #  sha256 = "1iadb4vdmzsbwrkrkl6y1q13676p17smvpjw26896ky17z7305wl";
      #})
      # hyperlink users
      (fetchpatch {
        url = https://github.com/QMatrixClient/Quaternion/pull/580.patch;
        sha256 = "04lhy7akkd2nlpbqfx4fva2f5fxmnwyjw1433kfrabycqjszab98";
      })
    ];

    buildInputs = [ qtbase qtmultimedia qtquickcontrols qtkeychain qttools library ];

    nativeBuildInputs = [ cmake ];

    postInstall = if stdenv.isDarwin then ''
      mkdir -p $out/Applications
      mv $out/bin/quaternion.app $out/Applications
      rmdir $out/bin || :
    '' else ''
      substituteInPlace $out/share/applications/quaternion.desktop \
        --replace 'Exec=quaternion' "Exec=$out/bin/quaternion"
    '';

    meta = with lib; {
      description = "Cross-platform desktop IM client for the Matrix protocol";
      homepage    = https://matrix.org/docs/projects/client/quaternion.html;
      license     = licenses.gpl3;
      maintainers = with maintainers; [ peterhoeg ];
      inherit (qtbase.meta) platforms;
      inherit version;
    };
  };

  qmtx_colors = libqmatrixclient_0_5.overrideAttrs(o: {
    patches = (o.patches or []) ++ [
      (fetchpatch {
        url = https://github.com/QMatrixClient/libqmatrixclient/pull/298.patch;
        sha256 = "05h0wvx45rlqyzz1zfj24l7cwmxrxwkv5f88fzcvqbfq1hwm0542";
      })
    ];
  });

in rec {
  quaternion     = generic "0.0.9.4"     "12mkwiqqbi4774kwl7gha72jyf0jf547acy6rw8ry249zl4lja54" "" qmtx_colors; # libqmatrixclient_0_5;
  quaternion-git = quaternion;
}
