{ stdenv, lib, fetchFromGitHub, qtbase, qtquickcontrols, cmake
, fetchpatch
, qttools, qtmultimedia
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

    buildInputs = [ qtbase qtmultimedia qtquickcontrols qttools library ];

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
  quaternion     = generic "0.0.9.4"     "05xl1vydznz8sbqx30grh135cy0bhxhnhyk68b1n0fp98lx4ba9d" "" qmtx_colors; # libqmatrixclient_0_5;
  quaternion-git = generic "f9fc184880cb43a5fb59fcb59a0a1355806121e4" "05xl1vydznz8sbqx30grh135cy0bhxhnhyk68b1n0fp98lx4ba9d" ""  qmtx_colors; # libqmatrixclient_0_5;
}
