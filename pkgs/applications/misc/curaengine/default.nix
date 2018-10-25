{ stdenv, fetchFromGitHub, fetchpatch, cmake, libarcus, stb }:

stdenv.mkDerivation rec {
  name = "curaengine-${version}";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner = "Ultimaker";
    repo = "CuraEngine";
    rev = version;
    sha256 = "083jmhzmb60rmqw0fhbnlxyblzkmpn3k6zc75xq90x5g3h60wib4";
  };

  patches = [
    # Fixed upstream, but not yet released
    (fetchpatch {
      url = "https://github.com/Ultimaker/CuraEngine/commit/5aad55bf67e52ce5bdb27a3925af8a4cab441b38.patch";
      sha256 = "1hxbslzhkvdg8p33mvlbrpw62gwfqpsdbfca6yhdng9hifl86j3f";
    })
  ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ libarcus stb ];

  cmakeFlags = [ "-DCURA_ENGINE_VERSION=${version}" ];

  meta = with stdenv.lib; {
    description = "A powerful, fast and robust engine for processing 3D models into 3D printing instruction";
    homepage = https://github.com/Ultimaker/CuraEngine;
    license = licenses.agpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ abbradar ];
  };
}
