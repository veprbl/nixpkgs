{ stdenv, go, buildGoModule, fetchgit }:

buildGoModule rec {
  name = "gotools-unstable-${version}";
  version = "2019-03-05";
  rev = "00c44ba9c14f88ffdd4fb5bfae57fe8dd6d6afb1";

  src = fetchgit {
    inherit rev;
    url = "https://go.googlesource.com/tools";
    sha256 = "04rpdi52j26szx5kiyfmwad1sg7lfplxrkbwkr3b1kfafh1whgw5";
  };

  modSha256 = "00yjcs26cm5civ96sikbd3wjmhx153xbyd805s3shca1mg99y7mm";

  preConfigure = ''
    # Make the builtin tools available here

    mkdir -p $out/bin
    export GTD="$(HOME=$TMPDIR go env GOTOOLDIR)"
    echo "Linking tools from original GOTOOLDIR(=$GTD)..."

    find "$GTD" -maxdepth 1 -type f -executable -print0 | xargs -tr -0 ln -sv -t $out/bin

    export GOTOOLDIR=$out/bin
  '';

  excludedPackages = "\\("
    + stdenv.lib.concatStringsSep "\\|" ([ "testdata" ] ++ stdenv.lib.optionals (stdenv.lib.versionAtLeast go.meta.branch "1.5") [ "vet" "cover" ])
    + "\\)";

  # Set GOTOOLDIR for derivations adding this to buildInputs
  postInstall = ''
    mkdir -p $out/nix-support
    substituteAll ${../../go-modules/tools/setup-hook.sh} $out/nix-support/setup-hook.tmp
    cat $out/nix-support/setup-hook.tmp >> $out/nix-support/setup-hook
    rm $out/nix-support/setup-hook.tmp
  '';

  # Do not copy this without a good reason for enabling
  # In this case tools is heavily coupled with go itself and embeds paths.
  allowGoReference = true;
}
