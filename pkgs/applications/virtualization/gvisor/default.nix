{
  stdenv
, pkgs
, fetchFromGitHub
, cacert
, symlinks
, writeScript

, coreutils
, bash
, bazel
, git
, go
, python
}:

let

  # gvisor doesn't have any releases yet
  version = "2018-11-10";

  # From the Bazel docs:
  #   Beneath the outputUserRoot directory, we also create an outputBase
  #   directory whose name is the MD5 hash of the path name of the workspace
  #   directory.
  #
  # The default `fetchzip` arguments will unpack our file as the name `source`,
  # and the Nix sandbox builds things in the `/build` directory. Thus, we can
  # predict this hash and calculate it here:
  outputBaseHash = builtins.hashString "md5" "/build/source";

  # Source from GitHub with additional patches.
  patchedSource = fetchFromGitHub {
    owner = "google";
    repo  = "gvisor";
    rev   = "d97ccfa346d23d99dcbe634a10fa5d81b089100d";

    # NOTE: this is the output of the whole fixed-output derivation, so
    # `nix-prefetch-git` won't work to obtain this. The easiest way is to just
    # change it and see what breaks :)
    sha256 = "0mcdjx2zx5v9qqj75bsmj6pmd63prhaahi7c87j1k77vggs8hxyz";

    # Patch the source to:
    #   - Use our host Go toolchain
    #   - Fix hard-coded paths to Bash, coreutils, etc.
    #   - Fetch a specific version of abseil instead of the `master` branch
    extraPostFetch =
      let
        # master as of 2018-11-10
        abseilRev  = "070f6e47b33a2909d039e620c873204f78809492";
        abseilHash = "a4298dca4149157b379588bec19493bcab56f8b3fb119ea81303b04d70af1b48";

      in ''
        substituteInPlace "$out/WORKSPACE" \
          --replace 'go_register_toolchains(go_version="1.11.2")' 'go_register_toolchains(go_version="host")' \
          --replace \
            'urls = ["https://github.com/abseil/abseil-cpp/archive/master.zip"],' \
            'urls = ["https://github.com/abseil/abseil-cpp/archive/${abseilRev}.zip"], sha256 = "${abseilHash}",'

        find "$out" -name '*.sh' -exec \
          sed -i 's|#!/bin/bash|#!/bin/sh|g' {} \;
      '';
  };

  # Bazel command we run.
  bazelCmd = "USER=nix bazel";

  # Use Bazel to fetch dependencies as a fixed-output derivation, so that we
  # have network access.
  bazelDependencies = stdenv.mkDerivation rec {
    inherit version;
    name = "gvisor-build-dependencies-${version}";

    # The actual source
    src = patchedSource;

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "0430pn3q71r6pyxq32k2n1zhnp9hvs5mizvw3zy6zwrsv3fchdb6";

    nativeBuildInputs = [ bazel git go symlinks ];
    GIT_SSL_CAINFO = "${cacert}/etc/ssl/certs/ca-bundle.crt";

    builder = writeScript "builder.sh" ''
      source ${stdenv}/setup

      # Copy sources into our build directory
      cp -pr --reflink=auto -- "$src" ./source
      chmod -R u+w -- ./source
      cd source

      # Prefetch dependencies with Bazel
      export TEST_TMPDIR=$PWD/bazel_root_dir
      ${bazelCmd} sync

      outputUserRoot="$TEST_TMPDIR/_bazel_nix"
      outputBase="$outputUserRoot/${outputBaseHash}"
      if [[ ! -d "$outputBase" ]]; then
        echo "did not find outputBase directory: $outputBase"
        exit 1
      fi

      # Find git repositories and remove the `.git` directory entirely; Bazel
      # appears to work just fine, and this is a major source of
      # nondeterminism.
      find "$outputBase/external" -name '.git' -type d -exec rm -rf {} '+'

      # Convert symbolic links to relative ones
      ( cd "$outputBase/external" && symlinks -cr . )

      # Copy the now-prefetched dependencies to our output directory
      mkdir -p "$out"
      cp -aR "$outputBase/external"/* $out/

      # This is a link outside the `external` directory, and Bazel appears to
      # re-create it just fine, so remove it.
      rm "$out/bazel_tools"
    '';
  };

in

stdenv.mkDerivation rec {
  inherit version;
  name = "gvisor-${version}";

  src = patchedSource;

  nativeBuildInputs = [ bazel go python ];

  buildPhase = ''
    export TEST_TMPDIR=$PWD/bazel_root_dir
    mkdir -p "$TEST_TMPDIR"

    # Run bazel once to initialize the temporary directory
    ${bazelCmd} help >/dev/null 2>&1 || true

    # Copy inputs into the `external` directory
    outputUserRoot="$TEST_TMPDIR/_bazel_nix"
    outputBase="$outputUserRoot/${outputBaseHash}"
    if [[ ! -d "$outputBase" ]]; then
      echo "did not find outputBase directory: $outputBase"
      exit 1
    fi

    cp -pr --reflink=auto -- "${bazelDependencies}" "$outputBase/external"
    chmod -R u+w -- "$outputBase/external"

    # Convert symlinks in the external directory back to absolute, since that's
    # how Bazel expects things.
    find "$outputBase/external" -type l -execdir bash -c 'ln -sfn "$(readlink -f "$0")" "$0"' {} \;

    # Actually run the build
    ${bazelCmd} build //runsc:runsc
  '';

  # TODO: use build event protocol(?) in order to find the right output file,
  # if we expand the set of supported platforms
  installPhase = ''
    install -Dm755 ./bazel-bin/runsc/linux_amd64_pure_stripped/runsc $out/bin/runsc
  '';

  meta = with stdenv.lib; {
    description = "Container Runtime Sandbox";
    homepage = https://github.com/google/gvisor;
    license = licenses.asl20;
    maintainers = with maintainers; [ andrew-d ];
    platforms = [ "x86_64-linux" ];
  };
}
