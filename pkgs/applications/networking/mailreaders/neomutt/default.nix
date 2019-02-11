{ stdenv, fetchFromGitHub, gettext, makeWrapper, tcl, which, writeScript
, ncurses, perl , cyrus_sasl, gss, gpgme, libgpgerror, kerberos, libidn2, libxml2, notmuch, openssl
, lmdb, libxslt, docbook_xsl, docbook_xml_dtd_42, mailcap
}:

let
  muttWrapper = writeScript "mutt" ''
    #!${stdenv.shell} -eu

    echo 'The neomutt project has renamed the main binary from `mutt` to `neomutt`.'
    echo ""
    echo 'This wrapper is provided for compatibility purposes only. You should start calling `neomutt` instead.'
    echo ""
    read -p 'Press any key to launch NeoMutt...' -n1 -s
    exec neomutt "$@"
  '';

in stdenv.mkDerivation rec {
  version = "20190208";
  name = "neomutt-${version}";

  src = fetchFromGitHub {
    owner  = "neomutt";
    repo   = "neomutt";
    #rev    = "neomutt-${version}";
    rev = "844319ad9daa5101417261f465b18b412960e044";
    sha256 = "1249asjwslw8980lpdqqhcbbk76360n8p5h1clm2s173l4hlbpg5";
  };

  buildInputs = [
    cyrus_sasl gss gpgme libgpgerror kerberos libidn2 ncurses
    notmuch openssl perl lmdb
    mailcap
  ];

  nativeBuildInputs = [
    docbook_xsl docbook_xml_dtd_42 gettext libxml2 libxslt.bin makeWrapper tcl which
  ];

  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace contrib/smime_keys \
      --replace /usr/bin/openssl ${openssl}/bin/openssl

    for f in doc/*.{xml,xsl}*  ; do
      substituteInPlace $f \
        --replace http://docbook.sourceforge.net/release/xsl/current     ${docbook_xsl}/share/xml/docbook-xsl \
        --replace http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd ${docbook_xml_dtd_42}/xml/dtd/docbook/docbookx.dtd
    done


    # allow neomutt to map attachments to their proper mime.types if specified wrongly
    # and use a far more comprehensive list than the one shipped with neomutt
    substituteInPlace sendlib.c \
      --replace /etc/mime.types ${mailcap}/etc/mime.types

  '';

  configureFlags = [
    "--gpgme"
    "--with-gpgme=${gpgme.dev}"
    "--disable-idn"
    "--idn2"
    "--gss"
    "--lmdb"
    "--notmuch"
    "--ssl"
    "--sasl"
    "--with-homespool=mailbox"
    "--with-mailpath="
    # Look in $PATH at runtime, instead of hardcoding /usr/bin/sendmail
    "ac_cv_path_SENDMAIL=sendmail"
    "--debug"
  ];

  postInstall = ''
    cp ${muttWrapper} $out/bin/mutt
    wrapProgram "$out/bin/neomutt" --prefix PATH : "$out/libexec/neomutt"
  '';

  doCheck = true;

  checkTarget = "test";

  meta = with stdenv.lib; {
    description = "A small but very powerful text-based mail client";
    homepage    = http://www.neomutt.org;
    license     = licenses.gpl2Plus;
    maintainers = with maintainers; [ cstrahan erikryb jfrankenau vrthra ];
    platforms   = platforms.unix;
  };
}
