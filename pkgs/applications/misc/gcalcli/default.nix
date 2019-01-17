{ stdenv, lib, fetchFromGitHub, python3
, libnotify ? null }:

with python3.pkgs;

buildPythonApplication rec {
  version = "4.0.0a4.0.1"; # XXX: not really
  name = "gcalcli-${version}";

  src = fetchFromGitHub {
    owner  = "insanum";
    repo   = "gcalcli";
    #rev    = "v${version}";
    rev = "92fab4d39db319d91e5473d8df4cfef80b27e49c";
    sha256 = "1z52dh8p7p0b7v70n9jkvgqs81iwx7bhpzimxmfa0ka6gf2bvvxv";
  };

  postPatch = lib.optionalString stdenv.isLinux ''
    substituteInPlace gcalcli/gcalcli.py --replace \
      "command = 'notify-send -u critical" \
      "command = '${libnotify}/bin/notify-send -u critical"
  '';

  propagatedBuildInputs = [
    dateutil gflags httplib2 parsedatetime six vobject
    google_api_python_client oauth2client uritemplate
  ] ++ lib.optional (!isPy3k) futures;

  # There are no tests as of 4.0.0a4
  doCheck = false;

  meta = with lib; {
    description = "CLI for Google Calendar";
    homepage = https://github.com/insanum/gcalcli;
    license = licenses.mit;
    maintainers = with maintainers; [ nocoolnametom ];
    inherit version;
  };
}
