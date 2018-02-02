{ stdenv, fetchFromGitHub, fetchurl, fetchzip,
# Native build inputs
cmake,
autoconf, automake, libtool,
pkgconfig,
bison, flex,
groff,
perl,
python,
# Runtime tools
time,
upx,
# Build inputs
ncurses,
libffi,
libxml2,
zlib,
# PE (Windows) data, huge space savings if not needed
withPEPatterns ? false,
}:

let
  version = "2018-01-31";
  support-version = "2017-12-15";

  rapidjson = fetchFromGitHub {
    owner = "Tencent";
    repo = "rapidjson";
    rev = "v1.1.0";
    sha256 = "1jixgb8w97l9gdh3inihz7avz7i770gy2j2irvvlyrq3wi41f5ab";
  };
  jsoncpp = fetchFromGitHub {
    owner = "open-source-parsers";
    repo = "jsoncpp";
    rev = "1.8.3";
    sha256 = "05gkmg6r94q8a0qdymarcjlnlvmy9s365m9jhz3ysvi71cr31lkz";
  };
  googletest = fetchFromGitHub {
    owner = "google";
    repo = "googletest";
    rev = "release-1.8.0";
    sha256 = "0bjlljmbf8glnd9qjabx73w6pd7ibv43yiyngqvmvgxsabzr8399";
  };
  tinyxml2 = fetchFromGitHub {
    owner = "leethomason";
    repo = "tinyxml2";
    rev = "5.0.1";
    sha256 = "015g8520a0c55gwmv7pfdsgfz2rpdmh3d1nq5n9bd65n35492s3q";
  };
  yara = fetchurl {
     url = "https://github.com/avast-tl/yara/archive/v1.0-retdec.zip";
     sha256 = "1bjrkgp1sgld2y7gvwrlrz5fs16521ink6xyq72v7yxj3vfa9gps";
  };
  openssl = fetchurl {
    url = "https://www.openssl.org/source/openssl-1.1.0f.tar.gz";
    sha256 = "0r97n4n552ns571diz54qsgarihrxvbn7kvyv8wjyfs9ybrldxqj";
  };

  retdec-support = fetchzip {
    url = "https://github.com/avast-tl/retdec-support/releases/download/${support-version}/retdec-support_${support-version}.tar.xz";
    sha256 = if withPEPatterns then "16pmrjmlr3sacf4dasi7lxhbsv3fwp78wbr4s48y01r99jlsnbqg"
                               else "0g1hklrpbsmsy9y4jcrlc221lk42ad607ydcrd8p77nr885kqyzg";
    # Removing PE signatures reduces this from 3.8GB -> 642MB (uncompressed)
    extraPostFetch = stdenv.lib.optionalString (!withPEPatterns) ''
      rm -rf $out/generic/yara_patterns/static-code/pe
    '';
    stripRoot = false;
  };
in stdenv.mkDerivation rec {
  name = "retdec-${version}";
  inherit version;

  src = fetchFromGitHub {
    owner = "avast-tl";
    repo = "retdec";
    rev = "6489bd2d36a090fbdc645aa864f0782a23c9555b";
    sha256 = "1mmcv9adl8ksdndbpi1yy3zq7hy8i47cpcajfxr8dyk2hq2sc7zc";
  };

  nativeBuildInputs = [ cmake autoconf automake libtool pkgconfig bison flex groff perl python ];

  buildInputs = [ ncurses libffi libxml2 zlib ];

  prePatch = ''
    find . -wholename "*/deps/rapidjson/CMakeLists.txt" -print0 | \
      xargs -0 sed -i -e 's|GIT_REPOSITORY.*|URL ${rapidjson}|'
    find . -wholename "*/deps/jsoncpp/CMakeLists.txt" -print0 | \
      xargs -0 sed -i -e 's|GIT_REPOSITORY.*|URL ${jsoncpp}|'
    find . -wholename "*/deps/googletest/CMakeLists.txt" -print0 | \
      xargs -0 sed -i -e 's|GIT_REPOSITORY.*|URL ${googletest}|'
    find . -wholename "*/deps/tinyxml2/CMakeLists.txt" -print0 | \
      xargs -0 sed -i -e 's|GIT_REPOSITORY.*|URL ${tinyxml2}|'

    find . -wholename "*/yaracpp/deps/CMakeLists.txt" -print0 | \
      xargs -0 sed -i -e 's|URL .*|URL ${yara}|'

    find . -wholename "*/deps/openssl/CMakeLists.txt" -print0 | \
      xargs -0 sed -i -e 's|OPENSSL_URL .*)|OPENSSL_URL ${openssl})|'

    cat > cmake/install-share.sh <<EOF
      #!/bin/sh
      mkdir -p $out/share/retdec/
      ln -s ${retdec-support} $out/share/retdec/support
    EOF
    chmod +x cmake/*.sh
    patchShebangs cmake/*.sh

    substituteInPlace scripts/unpack.sh --replace '	upx -d' '	${upx}/bin/upx -d'
    substituteInPlace scripts/config.sh --replace /usr/bin/time ${time}/bin/time
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A retargetable machine-code decompiler based on LLVM";
    homepage = https://retdec.com;
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
  };
}
