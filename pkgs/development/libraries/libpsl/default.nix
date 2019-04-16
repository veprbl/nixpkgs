{ stdenv, fetchFromGitHub, autoreconfHook, docbook_xsl, docbook_xml_dtd_43, gtk-doc, icu
, libxslt, pkgconfig, python3 }:

let

  listVersion = "2019-04-15";
  listSources = fetchFromGitHub {
    sha256 = "1p8afrxgi9sz1mvbl5fz6hgib1a94288pdz9ar36q9d357qaq5nr";
    rev = "033221af7f600bcfce38dcbfafe03b9a2269c4cc";
    repo = "list";
    owner = "publicsuffix";
  };

  libVersion = "0.21.0";

in stdenv.mkDerivation rec {
  name = "libpsl-${version}";
  version = "${libVersion}-list-${listVersion}";

  src = fetchFromGitHub {
    sha256 = "0ancgnydimw9w4cmfk6ykjddw51h0ja4g1x0yk80s8ybw2w5nr3b";
    rev = "libpsl-${libVersion}";
    repo = "libpsl";
    owner = "rockdaboot";
  };

  buildInputs = [ icu libxslt ];
  nativeBuildInputs = [ autoreconfHook docbook_xsl docbook_xml_dtd_43 gtk-doc pkgconfig python3 ];

  postPatch = ''
    substituteInPlace src/psl.c --replace bits/stat.h sys/stat.h
    patchShebangs src/psl-make-dafsa
  '';

  preAutoreconf = ''
    gtkdocize
  '';

  preConfigure = ''
    # The libpsl check phase requires the list's test scripts (tests/) as well
    cp -Rv "${listSources}"/* list
  '';
  configureFlags = [
    "--disable-builtin"
    "--disable-static"
    "--enable-gtk-doc"
    "--enable-man"
  ];

  enableParallelBuilding = true;

  doCheck = true;

  meta = with stdenv.lib; {
    description = "C library for the Publix Suffix List";
    longDescription = ''
      libpsl is a C library for the Publix Suffix List (PSL). A "public suffix"
      is a domain name under which Internet users can directly register own
      names. Browsers and other web clients can use it to avoid privacy-leaking
      "supercookies" and "super domain" certificates, for highlighting parts of
      the domain in a user interface or sorting domain lists by site.
    '';
    homepage = http://rockdaboot.github.io/libpsl/;
    license = licenses.mit;
    platforms = with platforms; linux ++ darwin;
  };
}
