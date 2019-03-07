{ stdenv, python3Packages, fetchFromGitHub, dialog }:

python3Packages.buildPythonApplication rec {
  pname = "certbot";
  version = "0.32.0";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "12k56cak5kd57svq9gkh12l8wb2agq5zpbxiicp6mxxryx7hfab0";
  };

  propagatedBuildInputs = with python3Packages; [
    ConfigArgParse
    acme
    configobj
    cryptography
    josepy
    parsedatetime
    psutil
    pyRFC3339
    pyopenssl
    pytz
    six
    zope_component
    zope_interface
  ];
  buildInputs = [ dialog ] ++ (with python3Packages; [ mock gnureadline ]);

  patchPhase = ''
    substituteInPlace certbot/notify.py --replace "/usr/sbin/sendmail" "/run/wrappers/bin/sendmail"
    substituteInPlace certbot/util.py --replace "sw_vers" "/usr/bin/sw_vers"
  '';

  postInstall = ''
    for i in $out/bin/*; do
      wrapProgram "$i" --prefix PYTHONPATH : "$PYTHONPATH" \
                       --prefix PATH : "${dialog}/bin:$PATH"
    done
  '';

  doCheck = !stdenv.isDarwin; # On Hydra Darwin tests fail with "Too many open files".

  meta = with stdenv.lib; {
    homepage = src.meta.homepage;
    description = "ACME client that can obtain certs and extensibly update server configurations";
    platforms = platforms.unix;
    maintainers = [ maintainers.domenkozar ];
    license = licenses.asl20;
  };
}
