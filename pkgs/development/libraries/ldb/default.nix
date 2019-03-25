{ stdenv, fetchurl, python3, pkgconfig, which, readline, tdb, talloc, tevent
, popt, libxslt, docbook_xsl, docbook_xml_dtd_42, cmocka
}:

stdenv.mkDerivation rec {
  pname = "ldb";
  version = "1.6.3";

  src = fetchurl {
    url = "mirror://samba/${pname}/${pname}-${version}.tar.gz";
    sha256 = "01livdy3g073bm6xnc8zqnqrxg53sw8q66d1903z62hd6g87whsa"                                                                                                                                                             ;
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ pkgconfig python3 docbook_xsl docbook_xml_dtd_42 ];
  buildInputs = [
    readline tdb talloc tevent popt
    libxslt
    cmocka
  ];

  patches = [
    # CVE-2019-3824
    # downloading the patch from debian as they have ported the patch from samba to ldb but otherwise is identical to
    # https://bugzilla.samba.org/attachment.cgi?id=14857
    (fetchurl {
      name = "CVE-2019-3824.patch";
      url = "https://sources.debian.org/data/main/l/ldb/2:1.1.27-1+deb9u1/debian/patches/CVE-2019-3824-master-v4-5-02.patch";
      sha256 = "1idnqckvjh18rh9sbq90rr4sxfviha9nd1ca9pd6lai0y6r6q4yd";
    })
  ];

  preConfigure = ''
    patchShebangs buildtools/bin/waf
  '';

  configureFlags = [
    "--bundled-libraries=NONE"
    "--builtin-libraries=replace"
    "--disable-python"
  ];

  stripDebugList = "bin lib modules";

  meta = with stdenv.lib; {
    description = "A LDAP-like embedded database";
    homepage = https://ldb.samba.org/;
    license = licenses.lgpl3Plus;
    platforms = platforms.all;
  };
}
