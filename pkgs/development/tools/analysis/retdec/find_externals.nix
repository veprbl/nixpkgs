# For maintainer use!
# This automates gathering information about dependencies
# to make it easier to track across updates.
{ pkgs ? import ../../../../.. { }, src ? pkgs.retdec.src }:

# External dependencies are in deps/, each having a directory
# containing a CMakeLists.txt file for the project.
#
# In these files are invocations of ExternalProject_Add
# that specify the URL and hash to use!
#
# Upstream was nice and normalized the style and methods used,
# with dependency's CMakeLists.txt containing two lines
# similar to the following:
#
#   URL https://github.com/avast-tl/capstone/archive/27c713fe4f6eaf9721785932d850b6291a6073fe.zip
#   URL_HASH SHA256=4d8d0461d7d5737893253698cd0b6d0d64545c1a74b166e8b1d823156a3109cb
#
# How convenient!
# The code below just grep's out this information and
# generates a Nix file describing our findings.

pkgs.runCommand "find_externals" {
  nativeBuildInputs = [ pkgs.gnugrep ];
} ''
  unpackFile ${src}

  :> deps.nix

  echo "{" >> deps.nix
  for d in source/deps/*/; do
    n=$(basename $d)

    # Skip OpenSSL, prefer system version
    # (and it doesn't match the pattern we look for)
    [[ $n == "openssl" ]] && continue

    echo "Extracting info for dep $n ..."
    f=$d/CMakeLists.txt
    [ -f $f ] || (echo "error: unexpected organization"; exit 1)

    url=$(grep -oP "URL \K.+" $f)
    sha256=$(grep -oP "URL_HASH SHA256=\K.+" $f)

    cat >> deps.nix <<EOF
  "$n" = {
    url = "$url";
    sha256 = "$sha256";
  };
EOF
  done
  echo "}" >> deps.nix

  mkdir -p $out
  mv deps.nix $out/
''
