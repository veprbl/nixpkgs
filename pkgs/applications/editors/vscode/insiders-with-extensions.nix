{ stdenv, lib, fetchurl, runCommand, buildEnv, vscode-insiders, which, writeScript
, vscodeExtensions ? [] }:

let

  wrappedPkgVersion = lib.getVersion vscode-insiders;
  wrappedPkgName = lib.removeSuffix "-${wrappedPkgVersion}" vscode-insiders.name;

  combinedExtensionsDrv = buildEnv {
    name = "${wrappedPkgName}-extensions-${wrappedPkgVersion}";
    paths = vscodeExtensions;
  };

  wrappedExeName = "code-insiders";
  exeName = wrappedExeName;

  wrapperExeFile = writeScript "${exeName}" ''
    #!${stdenv.shell}
    exec ${vscode-insiders}/bin/${wrappedExeName} \
      --extensions-dir "${combinedExtensionsDrv}/share/${wrappedPkgName}/extensions" \
      "$@"
  '';

in

# When no extensions are requested, we simply redirect to the original
# non-wrapped vscode executable.
runCommand "${wrappedPkgName}-with-extensions-${wrappedPkgVersion}" {
  buildInputs = [ vscode-insiders which ];
  dontPatchELF = true;
  dontStrip = true;
  meta = vscode-insiders.meta;
} ''
  mkdir -p "$out/bin"
  mkdir -p "$out/share/applications"
  mkdir -p "$out/share/pixmaps"

  ln -sT "${vscode-insiders}/share/applications/code.desktop" "$out/share/applications/code.desktop"
  ln -sT "${vscode-insiders}/share/pixmaps/code.png" "$out/share/pixmaps/code.png"
  ${if [] == vscodeExtensions
    then ''
      ln -sT "${vscode-insiders}/bin/${wrappedExeName}" "$out/bin/${exeName}"
    ''
    else ''
      ln -sT "${wrapperExeFile}" "$out/bin/${exeName}"
    ''}
''
