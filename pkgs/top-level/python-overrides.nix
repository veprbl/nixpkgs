{ pkgs, python, self }:
  with pkgs.lib;

{
  django = { doCheck = false; };
  django-templatetag-sugar = { doCheck = false; };
  httpagentparser = { doCheck = false; };
  setproctitle = { doCheck = false; };
  email-reply-parser = { doCheck = false; };
  beautifulsoup = { doCheck = false; };
  cssutils = p: { doCheck=false; buildInputs= p.buildInputs ++ [pkgs.unzip]; };
  wsgiproxy2 = p: { buildInputs= p.buildInputs ++ [pkgs.unzip]; };
  greenlet = p: { buildInputs= p.buildInputs ++ [pkgs.unzip]; };
  pyquery = p: { buildInputs= p.buildInputs ++ [pkgs.unzip]; };
  webtest = p: { buildInputs= p.buildInputs ++ [pkgs.unzip]; };
  sh = { doCheck=false; };
  pytest = { doCheck=false; };
  "web.py" = { doCheck=false; };
  redis = { doCheck=false; };
  blinker = { doCheck=false; };
  thoonk = { doCheck=false; };
  python-openid = { doCheck=false; };
  bottle = { doCheck=false; };
  cql = { doCheck=false; };
  cqlsh = { doCheck=false; };
  logan = { doCheck=false; };
  ccm = { doCheck=false; };
  beautifulsoup4 = { doCheck=false; };
  casscache = { doCheck=false; };
  django-celery = { doCheck = false; };
  flask-login = { doCheck = false; };
  protobuf = { doCheck = false; };
  pysqlite = { buildInputs=[pkgs.sqlite]; doCheck = false; };
  riak = { doCheck = false; }; # connection refused
  django-paging = { doCheck=false; }; # failed tests 
  paste = { doCheck=false; }; # failed tests 
  pep8 = { doCheck=false; }; # failed tests 
  oauth2 = { doCheck=false; }; # failed tests 
  werkzeug = { doCheck=false; }; # failed tests 
  cssselect = { doCheck=false; }; # failed tests
  celery = { doCheck=false; }; # failed tests
  raven = { doCheck=false; }; # failed tests
  tornado = { doCheck=false; }; # failed tests
  httpretty = { doCheck=false; }; # failed tests
  nydus = { doCheck = false; };  # sentry django version conflict
  pylibmc = { buildInputs=[pkgs.libmemcached pkgs.zlib]; doCheck=false; };
  pyyaml = { buildInputs=[pkgs.libyaml]; };
  lxml = { buildInputs=[pkgs.libxml2 pkgs.libxslt]; };
  eventlet = p: { buildInputs=p.buildInputs ++ [pkgs.openssl]; doCheck=false;};
  psycopg2 = { buildInputs=[pkgs.postgresql]; doCheck = false; };
  blist = {
    preConfigure = ''
      substituteInPlace setup.py --replace "import distribute_setup" ""
      substituteInPlace setup.py --replace "distribute_setup.use_setuptools()" ""
    '';
  };
  sentry = p: {
    doCheck = false;
    propagatedBuildInputs = p.propagatedBuildInputs ++ [self.pysqlite];
  };
}
