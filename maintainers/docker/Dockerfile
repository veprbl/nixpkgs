FROM nixos/nix:1.9
RUN set -x \
        && nix-channel --remove nixpkgs \
        && nix-channel --add http://nixos.org/releases/nixpkgs/nixpkgs-15.06pre63766.8e56452 nixpkgs \
        && nix-channel --update nixpkgs
