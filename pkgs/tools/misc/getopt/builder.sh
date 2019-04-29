source $stdenv/setup
installFlags="prefix=$out"
makeFlags="WITHOUT_GETTEXT=1 LIBCGETOPT=0"
genericBuild
