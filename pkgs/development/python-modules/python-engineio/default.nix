{ stdenv, buildPythonPackage, fetchFromGitHub
, aiohttp
, eventlet
, iana-etc
, libredirect
, mock
, requests
, six
, tornado
, websocket_client
, websockets
, pytest
}:

buildPythonPackage rec {
  pname = "python-engineio";
  version = "3.13.2";

  src = fetchFromGitHub {
    owner = "miguelgrinberg";
    repo = "python-engineio";
    rev = "v${version}";
    sha256 = "1hn5nnxp7y2dpf52vrwdxza2sqmzj8admcnwgjkmcxk65s2dhvy1";
  };

  propagatedBuildInputs = [
    six
  ];

  checkInputs = [
    aiohttp
    eventlet
    mock
    requests
    tornado
    websocket_client
    websockets
    pytest
  ];

  # make /etc/protocols accessible to fix socket.getprotobyname('tcp') in sandbox
  preCheck = stdenv.lib.optionalString stdenv.isLinux ''
    export NIX_REDIRECTS=/etc/protocols=${iana-etc}/etc/protocols \
      LD_PRELOAD=${libredirect}/lib/libredirect.so
  '';
  postCheck = "unset NIX_REDIRECTS LD_PRELOAD";

  meta = with stdenv.lib; {
    description = "Engine.IO server";
    homepage = "https://github.com/miguelgrinberg/python-engineio/";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
