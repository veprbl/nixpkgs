{ stdenv, fetchurl, libidn, openssl, makeWrapper, fetchhg
, lua5
, withLibevent ? true
, withDBI ? true
# use withExtraLibs to add additional dependencies of community modules
, withExtraLibs ? [ ]
, withOnlyInstalledCommunityModules ? [ ]
, withCommunityModules ? [ ] }:


with stdenv.lib;

let
  libs        = with lua5.pkgs; [ luazlib luasocket luasec luaexpat luafilesystem luabitop ]
                ++ optional withLibevent luaevent
                ++ optional withDBI luadbi
                ++ withExtraLibs;
  luaEnv = lua5.withPackages(ps: with ps; libs);
in

stdenv.mkDerivation rec {
  version = "0.10.0";
  name = "prosody-${version}";

  src = fetchurl {
    url = "http://prosody.im/downloads/source/${name}.tar.gz";
    sha256 = "1644jy5dk46vahmh6nna36s79k8k668sbi3qamjb4q3c4m3y853l";
  };

  communityModules = fetchhg {
    url = "https://hg.prosody.im/prosody-modules";
    rev = "150a7bd59043";
    sha256 = "0nfx3lngcy88nd81gb7v4kh3nz1bzsm67bxgpd2lprk54diqcrz1";
  };

  buildInputs = [ makeWrapper libidn openssl ];
  propagatedBuildInputs = [ luaEnv ];

  configureFlags = [
    "--ostype=linux"
    "--with-lua-include=${lua5}/include"
    "--with-lua-bin=${luaEnv}/bin"
  ];

  postInstall = ''
      ${concatMapStringsSep "\n" (module: ''
        cp -r $communityModules/mod_${module} $out/lib/prosody/modules/
      '') (withCommunityModules ++ withOnlyInstalledCommunityModules)}
      wrapProgram $out/bin/prosodyctl \
        --add-flags '--config "prosody.cfg.lua"'
    '';

  passthru.communityModules = withCommunityModules;

  meta = {
    description = "Open-source XMPP application server written in Lua";
    license = licenses.mit;
    homepage = https://prosody.im;
    platforms = platforms.linux;
    maintainers = with maintainers; [ fpletz globin ];
  };
}
