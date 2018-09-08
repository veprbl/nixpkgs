#Adapted from
#https://github.com/rycee/home-manager/blob/9c1b3735b402346533449efc741f191d6ef578dd/home-manager/default.nix

{ bash, coreutils, less, stdenv, makeWrapper, fetchFromGitHub }:

stdenv.mkDerivation rec {

  name = "home-manager-${version}";
  version = "2018-09-07";

  src = fetchFromGitHub{
    owner = "rycee";
    repo = "home-manager";
    rev = "453d0494fbdc1d999a9e0c17330b3a648fcead94";
    sha256 = "06hhxwc3kpgy0dx0r7v1jm53p4z4zwl10jsw5f30jral8hc6d3c9";
  };

  nativeBuildInputs = [ makeWrapper ];
  dontBuild = true;

  installPhase = ''
    install -v -D -m755 ${src}/home-manager/home-manager $out/bin/home-manager

    substituteInPlace $out/bin/home-manager \
      --subst-var-by bash "${bash}" \
      --subst-var-by coreutils "${coreutils}" \
      --subst-var-by less "${less}" \
      --subst-var-by HOME_MANAGER_PATH '${src}'
  '';

  meta = with stdenv.lib; {
    description = "A user environment configurator";
    maintainers = with maintainers; [ rycee ];
    platforms = platforms.linux;
    license = licenses.mit;
  };

}
