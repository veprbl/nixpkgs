{ pkgs, python, self, overrides }:
  with pkgs.lib;
let

  fetchurl = pkgs.fetchurl;

  callOverride = pkg: override:
    if (isFunction override) then (override pkg) else override;

  attrByPathAlternatives = alt: default: e:
    if alt==[] then default else
      attrByPath (head alt) (attrByPathAlternatives (drop 1 alt) default e) e;

  overridablePythonPackage = pkg: self.buildPythonPackage (
    pkg // (callOverride pkg (
      attrByPathAlternatives ([[pkg.basename] [pkg.name]]) {} overrides)
    )
  );
in {}
############### Aliases #####################################################

// (optionalAttrs (python.executable == "python2.7") {
  
  sentry = self."sentry-6.4.4";
  
})


############### Packages ####################################################
// {}

// (optionalAttrs (python.executable == "python2.7") {
  
  "redis-2.8.0" = overridablePythonPackage {
    name = "redis-2.8.0";
    basename = "redis";
    version = "2.8.0";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/r/redis/redis-2.8.0.tar.gz";
        md5 = "3a5b1b96d70852a2581a0b28f6122902";
    };

    buildInputs = [ self."pytest-2.5.2" ];
    propagatedBuildInputs = [ ];
  };
  
  "south-0.8.2" = overridablePythonPackage {
    name = "south-0.8.2";
    basename = "south";
    version = "0.8.2";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/S/South/South-0.8.2.tar.gz";
        md5 = "89e61dd2cddab43d4de73d82321c61e6";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "amqp-1.0.13" = overridablePythonPackage {
    name = "amqp-1.0.13";
    basename = "amqp";
    version = "1.0.13";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/a/amqp/amqp-1.0.13.tar.gz";
        md5 = "33e9e59f71a396f9cdd5d5d6a3d2e5d5";
    };

    buildInputs = [ self."mock-1.0.1" self."coverage-3.6" self."unittest2-0.5.1" self."nose-cover3-0.1.0" self."nose-1.3.0" ];
    propagatedBuildInputs = [ ];
  };
  
  "cov-core-1.7" = overridablePythonPackage {
    name = "cov-core-1.7";
    basename = "cov-core";
    version = "1.7";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/c/cov-core/cov-core-1.7.tar.gz";
        md5 = "59c1e22e636633e10120beacbf45b28c";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."coverage-3.6" ];
  };
  
  "oauth2-1.5.211" = overridablePythonPackage {
    name = "oauth2-1.5.211";
    basename = "oauth2";
    version = "1.5.211";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/o/oauth2/oauth2-1.5.211.tar.gz";
        md5 = "987ad7365a70e2286bd1cebb344debbc";
    };

    buildInputs = [ self."mock-1.0.1" self."coverage-3.6" ];
    propagatedBuildInputs = [ self."httplib2-0.8" ];
  };
  
  "exam-0.10.2" = overridablePythonPackage {
    name = "exam-0.10.2";
    basename = "exam";
    version = "0.10.2";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/e/exam/exam-0.10.2.tar.gz";
        md5 = "78f522161a10c54450dd7ddf516b9933";
    };

    buildInputs = [ self."nose-1.3.0" ];
    propagatedBuildInputs = [ self."mock-1.0.1" ];
  };
  
  "pytz-2013.9" = overridablePythonPackage {
    name = "pytz-2013.9";
    basename = "pytz";
    version = "2013.9";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/pytz/pytz-2013.9.tar.bz2";
        md5 = "ec7076947a46a8a3cb33cbf2983a562c";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "psycopg2-2.5.2" = overridablePythonPackage {
    name = "psycopg2-2.5.2";
    basename = "psycopg2";
    version = "2.5.2";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/psycopg2/psycopg2-2.5.2.tar.gz";
        md5 = "53d81793fbab8fee6e732a0425d50047";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "bottle-0.12.4" = overridablePythonPackage {
    name = "bottle-0.12.4";
    basename = "bottle";
    version = "0.12.4";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/b/bottle/bottle-0.12.4.tar.gz";
        md5 = "638af3414f3d4ae0a79152916d373bae";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "simplejson-3.3.3" = overridablePythonPackage {
    name = "simplejson-3.3.3";
    basename = "simplejson";
    version = "3.3.3";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/s/simplejson/simplejson-3.3.3.tar.gz";
        md5 = "38ff12d163e5cc8c592d609820869817";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "logan-0.5.9.1" = overridablePythonPackage {
    name = "logan-0.5.9.1";
    basename = "logan";
    version = "0.5.9.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/l/logan/logan-0.5.9.1.tar.gz";
        md5 = "51e6bc858ac04f229179d4f378051d54";
    };

    buildInputs = [ self."django-1.5.5" self."unittest2-0.5.1" self."mock-1.0.1" self."nose-1.3.0" ];
    propagatedBuildInputs = [ ];
  };
  
  "py-1.4.20" = overridablePythonPackage {
    name = "py-1.4.20";
    basename = "py";
    version = "1.4.20";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/py/py-1.4.20.tar.gz";
        md5 = "5f1708be5482f3ff6711dfd6cafd45e0";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "unittest2-0.5.1" = overridablePythonPackage {
    name = "unittest2-0.5.1";
    basename = "unittest2";
    version = "0.5.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/u/unittest2/unittest2-0.5.1.tar.gz";
        md5 = "a0af5cac92bbbfa0c3b0e99571390e0f";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "riak-2.0.2" = overridablePythonPackage {
    name = "riak-2.0.2";
    basename = "riak";
    version = "2.0.2";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/r/riak/riak-2.0.2.tar.gz";
        md5 = "ca02d8cae4566871b2f452f5b31c97bd";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."riak-pb-1.4.4.0" ];
  };
  
  "pytest-2.5.2" = overridablePythonPackage {
    name = "pytest-2.5.2";
    basename = "pytest";
    version = "2.5.2";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/pytest/pytest-2.5.2.tar.gz";
        md5 = "8ea3d1939e81514ccba9ba0e9566b5be";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."py-1.4.20" ];
  };
  
  "cssselect-0.9.1" = overridablePythonPackage {
    name = "cssselect-0.9.1";
    basename = "cssselect";
    version = "0.9.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/c/cssselect/cssselect-0.9.1.tar.gz";
        md5 = "c74f45966277dc7a0f768b9b0f3522ac";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "django-picklefield-0.3.1" = overridablePythonPackage {
    name = "django-picklefield-0.3.1";
    basename = "django-picklefield";
    version = "0.3.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/d/django-picklefield/django-picklefield-0.3.1.tar.gz";
        md5 = "69712c8744502f2bf179c7fbed0006ef";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."six-1.5.2" ];
  };
  
  "kombu-2.5.16" = overridablePythonPackage {
    name = "kombu-2.5.16";
    basename = "kombu";
    version = "2.5.16";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/k/kombu/kombu-2.5.16.tar.gz";
        md5 = "e6a883288a962be7c64af5e1806a0f9e";
    };

    buildInputs = [ self."mock-1.0.1" self."unittest2-0.5.1" self."nose-cover3-0.1.0" self."nose-1.3.0" ];
    propagatedBuildInputs = [ self."anyjson-0.3.3" self."amqp-1.0.13" ];
  };
  
  "paste-1.7.5.1" = overridablePythonPackage {
    name = "paste-1.7.5.1";
    basename = "paste";
    version = "1.7.5.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/P/Paste/Paste-1.7.5.1.tar.gz";
        md5 = "7ea5fabed7dca48eb46dc613c4b6c4ed";
    };

    buildInputs = [ self."nose-1.3.0" ];
    propagatedBuildInputs = [ ];
  };
  
  "eventlet-0.14.0" = overridablePythonPackage {
    name = "eventlet-0.14.0";
    basename = "eventlet";
    version = "0.14.0";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/e/eventlet/eventlet-0.14.0.tar.gz";
        md5 = "207119abce774018432225bd719403fb";
    };

    buildInputs = [ self."nose-1.3.0" ];
    propagatedBuildInputs = [ self."greenlet-0.4.2" ];
  };
  
  "waitress-0.8.8" = overridablePythonPackage {
    name = "waitress-0.8.8";
    basename = "waitress";
    version = "0.8.8";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/w/waitress/waitress-0.8.8.tar.gz";
        md5 = "c0a40f34b5410348579556cd4a21c1c2";
    };

    buildInputs = [ self."coverage-3.6" self."nose-1.3.0" ];
    propagatedBuildInputs = [ self."setuptools-2.2" ];
  };
  
  "webtest-2.0.14" = overridablePythonPackage {
    name = "webtest-2.0.14";
    basename = "webtest";
    version = "2.0.14";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/W/WebTest/WebTest-2.0.14.zip";
        md5 = "1c883b2abadd4e64cc8bcef082d41cce";
    };

    buildInputs = [ self."mock-1.0.1" self."nose-1.3.0" self."pastedeploy-1.5.2" self."coverage-3.6" self."pyquery-1.2.8" self."wsgiproxy2-0.4.1" ];
    propagatedBuildInputs = [ self."waitress-0.8.8" self."six-1.5.2" self."beautifulsoup4-4.3.2" self."webob-1.3.1" ];
  };
  
  "python-openid-2.2.5" = overridablePythonPackage {
    name = "python-openid-2.2.5";
    basename = "python-openid";
    version = "2.2.5";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/python-openid/python-openid-2.2.5.tar.gz";
        md5 = "393f48b162ec29c3de9e2973548ea50d";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "cssutils-0.9.10" = overridablePythonPackage {
    name = "cssutils-0.9.10";
    basename = "cssutils";
    version = "0.9.10";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/c/cssutils/cssutils-0.9.10.zip";
        md5 = "81b5c0294c54479a54548769eaa236f8";
    };

    buildInputs = [ self."mock-1.0.1" ];
    propagatedBuildInputs = [ ];
  };
  
  "pytest-timeout-0.3" = overridablePythonPackage {
    name = "pytest-timeout-0.3";
    basename = "pytest-timeout";
    version = "0.3";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/pytest-timeout/pytest-timeout-0.3.tar.gz";
        md5 = "46de81f106ab8a320c39a37d7d8f0429";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."pytest-2.5.2" ];
  };
  
  "thoonk-1.0.1.0" = overridablePythonPackage {
    name = "thoonk-1.0.1.0";
    basename = "thoonk";
    version = "1.0.1.0";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/t/thoonk/thoonk-1.0.1.0.tar.gz";
        md5 = "d9904f20fb4ffa007ac0849f845ff088";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."redis-2.8.0" ];
  };
  
  "sentry-6.4.4" = overridablePythonPackage {
    name = "sentry-6.4.4";
    basename = "sentry";
    version = "6.4.4";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/s/sentry/sentry-6.4.4.tar.gz";
        md5 = "8edcc624178256ab7b9f0d4bf98d6e3e";
    };

    buildInputs = [ self."nydus-0.10.6" self."cqlsh-4.1.1" self."pytest-cov-1.6" self."eventlet-0.14.0" self."pytest-django-2.6" self."exam-0.10.2" self."httpretty-0.8.0" self."casscache-0.1.0" self."mock-1.0.1" self."unittest2-0.5.1" self."python-coveralls-2.4.2" self."pytest-timeout-0.3" self."redis-2.8.0" self."riak-2.0.2" self."pytest-2.5.2" ];
    propagatedBuildInputs = [ self."redis-2.8.0" self."django-picklefield-0.3.1" self."pysqlite-2.6.3" self."python-memcached-1.53" self."django-paging-0.2.5" self."simplejson-3.3.3" self."south-0.8.2" self."logan-0.5.9.1" self."cssutils-0.9.10" self."python-dateutil-1.5" self."beautifulsoup-3.2.1" self."django-static-compiler-0.3.3" self."httpagentparser-1.2.2" self."setproctitle-1.1.8" self."django-celery-3.0.23" self."nydus-0.10.6" self."django-templatetag-sugar-0.1" self."pygments-1.6" self."urllib3-1.7.1" self."celery-3.0.24" self."raven-4.0.4" self."django-1.5.5" self."gunicorn-0.17.4" self."django-crispy-forms-1.2.8" self."django-social-auth-0.7.28" self."pynliner-0.5.0" self."email-reply-parser-0.2.0" ];
  };
  
  "coverage-3.6" = overridablePythonPackage {
    name = "coverage-3.6";
    basename = "coverage";
    version = "3.6";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/c/coverage/coverage-3.6.tar.gz";
        md5 = "67d4e393f4c6a5ffc18605409d2aa1ac";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "ccm-0.9" = overridablePythonPackage {
    name = "ccm-0.9";
    basename = "ccm";
    version = "0.9";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/c/ccm/ccm-0.9.tar.gz";
        md5 = "5e64e1f896a8d30ae226b44aa5ce209b";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."pyyaml-3.10" ];
  };
  
  "scales-1.0.3" = overridablePythonPackage {
    name = "scales-1.0.3";
    basename = "scales";
    version = "1.0.3";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/s/scales/scales-1.0.3.tar.gz";
        md5 = "cbc5eb8af86a805bd756b603f5e39320";
    };

    buildInputs = [ self."nose-1.3.0" ];
    propagatedBuildInputs = [ ];
  };
  
  "django-static-compiler-0.3.3" = overridablePythonPackage {
    name = "django-static-compiler-0.3.3";
    basename = "django-static-compiler";
    version = "0.3.3";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/d/django-static-compiler/django-static-compiler-0.3.3.tar.gz";
        md5 = "019f9aa814fa96cbb298686ce6abdeab";
    };

    buildInputs = [ self."pytest-2.5.2" self."unittest2-0.5.1" self."mock-1.0.1" self."exam-0.10.2" self."pytest-django-2.6" ];
    propagatedBuildInputs = [ self."django-1.5.5" ];
  };
  
  "pytest-cov-1.6" = overridablePythonPackage {
    name = "pytest-cov-1.6";
    basename = "pytest-cov";
    version = "1.6";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/pytest-cov/pytest-cov-1.6.tar.gz";
        md5 = "6da54d74bde9d200de45068ba2ea637a";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."pytest-2.5.2" self."cov-core-1.7" ];
  };
  
  "flask-login-0.2.9" = overridablePythonPackage {
    name = "flask-login-0.2.9";
    basename = "flask-login";
    version = "0.2.9";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/F/Flask-Login/Flask-Login-0.2.9.tar.gz";
        md5 = "19be7753993287820acfafd2b621d709";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."flask-0.10.1" ];
  };
  
  "httpagentparser-1.2.2" = overridablePythonPackage {
    name = "httpagentparser-1.2.2";
    basename = "httpagentparser";
    version = "1.2.2";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/h/httpagentparser/httpagentparser-1.2.2.tar.gz";
        md5 = "5e2e43769bf81d959484576f8dabaae4";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "nose-cover3-0.1.0" = overridablePythonPackage {
    name = "nose-cover3-0.1.0";
    basename = "nose-cover3";
    version = "0.1.0";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/n/nose-cover3/nose-cover3-0.1.0.tar.gz";
        md5 = "82f981eaa007b430679899256050fa0c";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "django-celery-3.0.23" = overridablePythonPackage {
    name = "django-celery-3.0.23";
    basename = "django-celery";
    version = "3.0.23";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/d/django-celery/django-celery-3.0.23.tar.gz";
        md5 = "76e72fa09319909da22adcf13a7e6af1";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."pytz-2013.9" self."celery-3.0.24" ];
  };
  
  "tornado-2.4.1" = overridablePythonPackage {
    name = "tornado-2.4.1";
    basename = "tornado";
    version = "2.4.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/t/tornado/tornado-2.4.1.tar.gz";
        md5 = "9b7146cbe7cce015e35856b592707b9b";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "pastedeploy-1.5.2" = overridablePythonPackage {
    name = "pastedeploy-1.5.2";
    basename = "pastedeploy";
    version = "1.5.2";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/P/PasteDeploy/PasteDeploy-1.5.2.tar.gz";
        md5 = "352b7205c78c8de4987578d19431af3b";
    };

    buildInputs = [ self."nose-1.3.0" ];
    propagatedBuildInputs = [ ];
  };
  
  "django-templatetag-sugar-0.1" = overridablePythonPackage {
    name = "django-templatetag-sugar-0.1";
    basename = "django-templatetag-sugar";
    version = "0.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/d/django-templatetag-sugar/django-templatetag-sugar-0.1.tar.gz";
        md5 = "f5b8bf6e4cb82f8affa761574bf3dae4";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "cql-1.4.0" = overridablePythonPackage {
    name = "cql-1.4.0";
    basename = "cql";
    version = "1.4.0";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/c/cql/cql-1.4.0.tar.gz";
        md5 = "ee3f4c5178335cb65bbbd55bb808e1ae";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."thrift-0.9.1" ];
  };
  
  "celery-3.0.24" = overridablePythonPackage {
    name = "celery-3.0.24";
    basename = "celery";
    version = "3.0.24";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/c/celery/celery-3.0.24.tar.gz";
        md5 = "e864856a849468f277031ac2c5fd65b6";
    };

    buildInputs = [ self."mock-1.0.1" self."unittest2-0.5.1" self."nose-cover3-0.1.0" self."nose-1.3.0" ];
    propagatedBuildInputs = [ self."billiard-2.7.3.34" self."python-dateutil-1.5" self."kombu-2.5.16" ];
  };
  
  "beautifulsoup4-4.3.2" = overridablePythonPackage {
    name = "beautifulsoup4-4.3.2";
    basename = "beautifulsoup4";
    version = "4.3.2";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/b/beautifulsoup4/beautifulsoup4-4.3.2.tar.gz";
        md5 = "b8d157a204d56512a4cc196e53e7d8ee";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "raven-4.0.4" = overridablePythonPackage {
    name = "raven-4.0.4";
    basename = "raven";
    version = "4.0.4";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/r/raven/raven-4.0.4.tar.gz";
        md5 = "addd094e0bbaa34d8a5fbc7264efaf0e";
    };

    buildInputs = [ self."pytz-2013.9" self."tornado-2.4.1" self."bottle-0.12.4" self."blinker-1.3" self."pytest-2.5.2" self."mock-1.0.1" self."web.py-0.37" self."paste-1.7.5.1" self."exam-0.10.2" self."webob-1.3.1" self."webtest-2.0.14" self."python-coveralls-2.4.2" self."pytest-cov-1.6" self."flask-login-0.2.9" self."flask-0.10.1" self."django-celery-3.0.23" self."anyjson-0.3.3" self."unittest2-0.5.1" self."celery-3.0.24" self."django-1.5.5" self."nose-1.3.0" self."pytest-django-lite-0.1.1" self."logbook-0.6.0" self."pep8-1.4.6" ];
    propagatedBuildInputs = [ ];
  };
  
  "nydus-0.10.6" = overridablePythonPackage {
    name = "nydus-0.10.6";
    basename = "nydus";
    version = "0.10.6";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/n/nydus/nydus-0.10.6.tar.gz";
        md5 = "97821cc8569784e054098bdbbafd9210";
    };

    buildInputs = [ self."django-1.5.5" self."nose-1.3.0" self."psycopg2-2.5.2" self."redis-2.8.0" self."pycassa-1.11.0" self."mock-1.0.1" self."thoonk-1.0.1.0" self."pylibmc-1.2.3" self."unittest2-0.5.1" self."riak-2.0.2" ];
    propagatedBuildInputs = [ ];
  };
  
  "nose-1.3.0" = overridablePythonPackage {
    name = "nose-1.3.0";
    basename = "nose";
    version = "1.3.0";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/n/nose/nose-1.3.0.tar.gz";
        md5 = "95d6d32b9d6b029c3c65674bd9e7eabe";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "gunicorn-0.17.4" = overridablePythonPackage {
    name = "gunicorn-0.17.4";
    basename = "gunicorn";
    version = "0.17.4";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/g/gunicorn/gunicorn-0.17.4.tar.gz";
        md5 = "464c1d0ce93c62ce039dc9a9493d26e3";
    };

    buildInputs = [ self."pytest-2.5.2" self."pytest-cov-1.6" ];
    propagatedBuildInputs = [ ];
  };
  
  "pytest-django-lite-0.1.1" = overridablePythonPackage {
    name = "pytest-django-lite-0.1.1";
    basename = "pytest-django-lite";
    version = "0.1.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/pytest-django-lite/pytest-django-lite-0.1.1.tar.gz";
        md5 = "38c3aaa6f616f9aeeb451e2ed592d92a";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."pytest-2.5.2" self."django-1.5.5" ];
  };
  
  "logbook-0.6.0" = overridablePythonPackage {
    name = "logbook-0.6.0";
    basename = "logbook";
    version = "0.6.0";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/L/Logbook/Logbook-0.6.0.tar.gz";
        md5 = "2c77da3adeafd191bb8071cc5ad447bf";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "protobuf-2.4.1" = overridablePythonPackage {
    name = "protobuf-2.4.1";
    basename = "protobuf";
    version = "2.4.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/protobuf/protobuf-2.4.1.tar.gz";
        md5 = "72f5141d20ab1bcae6b1e00acfb1068a";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."setuptools-2.2" ];
  };
  
  "cassandra-driver-1.0.1" = overridablePythonPackage {
    name = "cassandra-driver-1.0.1";
    basename = "cassandra-driver";
    version = "1.0.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/c/cassandra-driver/cassandra-driver-1.0.1.tar.gz";
        md5 = "8e153c5f9edc9f01c9403f85a3e1a00d";
    };

    buildInputs = [ self."ccm-0.9" self."pyyaml-3.10" self."mock-1.0.1" self."unittest2-0.5.1" self."nose-1.3.0" ];
    propagatedBuildInputs = [ self."blist-1.3.4" self."scales-1.0.3" self."futures-2.1.6" ];
  };
  
  "pyquery-1.2.8" = overridablePythonPackage {
    name = "pyquery-1.2.8";
    basename = "pyquery";
    version = "1.2.8";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/pyquery/pyquery-1.2.8.zip";
        md5 = "a2a9c23a88f7b2615b41722a3ddebeb7";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."lxml-3.3.2" self."cssselect-0.9.1" ];
  };
  
  "rednose-0.4.1" = overridablePythonPackage {
    name = "rednose-0.4.1";
    basename = "rednose";
    version = "0.4.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/r/rednose/rednose-0.4.1.tar.gz";
        md5 = "8f5705c22a7f898ded65dd7b64c1f6de";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."setuptools-2.2" self."python-termstyle-0.1.10" ];
  };
  
  "wsgiproxy2-0.4.1" = overridablePythonPackage {
    name = "wsgiproxy2-0.4.1";
    basename = "wsgiproxy2";
    version = "0.4.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/W/WSGIProxy2/WSGIProxy2-0.4.1.zip";
        md5 = "fb8937620dc24270916678f6f07e337b";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."six-1.5.2" self."webob-1.3.1" ];
  };
  
  "cqlsh-4.1.1" = overridablePythonPackage {
    name = "cqlsh-4.1.1";
    basename = "cqlsh";
    version = "4.1.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/c/cqlsh/cqlsh-4.1.1.tar.gz";
        md5 = "2ee57265566304d9ef4ab1bb67dbaaf0";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."unittest2-0.5.1" self."simplejson-3.3.3" self."cql-1.4.0" ];
  };
  
  "pysqlite-2.6.3" = overridablePythonPackage {
    name = "pysqlite-2.6.3";
    basename = "pysqlite";
    version = "2.6.3";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/pysqlite/pysqlite-2.6.3.tar.gz";
        md5 = "7ff1cedee74646b50117acff87aa1cfa";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "python-memcached-1.53" = overridablePythonPackage {
    name = "python-memcached-1.53";
    basename = "python-memcached";
    version = "1.53";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/python-memcached/python-memcached-1.53.tar.gz";
        md5 = "89570d26e7e7b15caa668a6b2678bd3c";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "django-social-auth-0.7.28" = overridablePythonPackage {
    name = "django-social-auth-0.7.28";
    basename = "django-social-auth";
    version = "0.7.28";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/d/django-social-auth/django-social-auth-0.7.28.tar.gz";
        md5 = "50fb14cc829fc28d6021e711e206f228";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."oauth2-1.5.211" self."django-1.5.5" self."python-openid-2.2.5" ];
  };
  
  "django-paging-0.2.5" = overridablePythonPackage {
    name = "django-paging-0.2.5";
    basename = "django-paging";
    version = "0.2.5";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/d/django-paging/django-paging-0.2.5.tar.gz";
        md5 = "282ef984815f73ce43189d288b2bae2a";
    };

    buildInputs = [ self."django-1.5.5" self."unittest2-0.5.1" ];
    propagatedBuildInputs = [ self."django-templatetag-sugar-0.1" ];
  };
  
  "pycassa-1.11.0" = overridablePythonPackage {
    name = "pycassa-1.11.0";
    basename = "pycassa";
    version = "1.11.0";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/pycassa/pycassa-1.11.0.tar.gz";
        md5 = "778b5ea6910104c701a3169f6636f358";
    };

    buildInputs = [ self."nose-1.3.0" ];
    propagatedBuildInputs = [ self."thrift-0.9.1" ];
  };
  
  "blinker-1.3" = overridablePythonPackage {
    name = "blinker-1.3";
    basename = "blinker";
    version = "1.3";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/b/blinker/blinker-1.3.tar.gz";
        md5 = "66e9688f2d287593a0e698cd8a5fbc57";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "futures-2.1.6" = overridablePythonPackage {
    name = "futures-2.1.6";
    basename = "futures";
    version = "2.1.6";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/f/futures/futures-2.1.6.tar.gz";
        md5 = "cfab9ac3cd55d6c7ddd0546a9f22f453";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "pyyaml-3.10" = overridablePythonPackage {
    name = "pyyaml-3.10";
    basename = "pyyaml";
    version = "3.10";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/P/PyYAML/PyYAML-3.10.tar.gz";
        md5 = "74c94a383886519e9e7b3dd1ee540247";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "mock-1.0.1" = overridablePythonPackage {
    name = "mock-1.0.1";
    basename = "mock";
    version = "1.0.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/m/mock/mock-1.0.1.tar.gz";
        md5 = "c3971991738caa55ec7c356bbc154ee2";
    };

    buildInputs = [ self."unittest2-0.5.1" ];
    propagatedBuildInputs = [ ];
  };
  
  "web.py-0.37" = overridablePythonPackage {
    name = "web.py-0.37";
    basename = "web.py";
    version = "0.37";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/w/web.py/web.py-0.37.tar.gz";
        md5 = "93375e3f03e74d6bf5c5096a4962a8db";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "httplib2-0.8" = overridablePythonPackage {
    name = "httplib2-0.8";
    basename = "httplib2";
    version = "0.8";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/h/httplib2/httplib2-0.8.tar.gz";
        md5 = "94cb8a3b196dfd19253c46609489d9f1";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "sh-1.09" = overridablePythonPackage {
    name = "sh-1.09";
    basename = "sh";
    version = "1.09";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/s/sh/sh-1.09.tar.gz";
        md5 = "b68a2f91de880dce042d4f03ec9e0f47";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "pytest-django-2.6" = overridablePythonPackage {
    name = "pytest-django-2.6";
    basename = "pytest-django";
    version = "2.6";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/pytest-django/pytest-django-2.6.tar.gz";
        md5 = "23ccf9e3b9cfbb96b656be7a0bf727c0";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."pytest-2.5.2" ];
  };
  
  "webob-1.3.1" = overridablePythonPackage {
    name = "webob-1.3.1";
    basename = "webob";
    version = "1.3.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/W/WebOb/WebOb-1.3.1.tar.gz";
        md5 = "20918251c5726956ba8fef22d1556177";
    };

    buildInputs = [ self."coverage-3.6" self."nose-1.3.0" ];
    propagatedBuildInputs = [ ];
  };
  
  "httpretty-0.8.0" = overridablePythonPackage {
    name = "httpretty-0.8.0";
    basename = "httpretty";
    version = "0.8.0";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/h/httpretty/httpretty-0.8.0.tar.gz";
        md5 = "2d5ea5205c358fa489e6de6fc74c00fa";
    };

    buildInputs = [ self."mock-1.0.1" self."nose-1.3.0" self."httplib2-0.8" self."requests-2.2.1" self."tornado-2.4.1" self."sure-1.2.5" self."coverage-3.6" ];
    propagatedBuildInputs = [ self."urllib3-1.7.1" ];
  };
  
  "markupsafe-0.18" = overridablePythonPackage {
    name = "markupsafe-0.18";
    basename = "markupsafe";
    version = "0.18";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-0.18.tar.gz";
        md5 = "f8d252fd05371e51dec2fe9a36890687";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "six-1.5.2" = overridablePythonPackage {
    name = "six-1.5.2";
    basename = "six";
    version = "1.5.2";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/s/six/six-1.5.2.tar.gz";
        md5 = "322b86d0c50a7d165c05600154cecc0a";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "python-coveralls-2.4.2" = overridablePythonPackage {
    name = "python-coveralls-2.4.2";
    basename = "python-coveralls";
    version = "2.4.2";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/python-coveralls/python-coveralls-2.4.2.tar.gz";
        md5 = "0f82aea84b365aae78de43e64ca6993d";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."sh-1.09" self."pyyaml-3.10" self."six-1.5.2" self."coverage-3.6" self."requests-2.2.1" ];
  };
  
  "blist-1.3.4" = overridablePythonPackage {
    name = "blist-1.3.4";
    basename = "blist";
    version = "1.3.4";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/b/blist/blist-1.3.4.tar.gz";
        md5 = "02e8bf33cffec9cc802f4567f39ffa6f";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "itsdangerous-0.23" = overridablePythonPackage {
    name = "itsdangerous-0.23";
    basename = "itsdangerous";
    version = "0.23";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/i/itsdangerous/itsdangerous-0.23.tar.gz";
        md5 = "985e726eb76f18aca81e703f0a6c6efc";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "greenlet-0.4.2" = overridablePythonPackage {
    name = "greenlet-0.4.2";
    basename = "greenlet";
    version = "0.4.2";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/g/greenlet/greenlet-0.4.2.zip";
        md5 = "580a8a5e833351f7abdaedb1a877f7ac";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "beautifulsoup-3.2.1" = overridablePythonPackage {
    name = "beautifulsoup-3.2.1";
    basename = "beautifulsoup";
    version = "3.2.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/B/BeautifulSoup/BeautifulSoup-3.2.1.tar.gz";
        md5 = "44656527ef3ac9874ac4d1c9f35f70ee";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "werkzeug-0.9.4" = overridablePythonPackage {
    name = "werkzeug-0.9.4";
    basename = "werkzeug";
    version = "0.9.4";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/W/Werkzeug/Werkzeug-0.9.4.tar.gz";
        md5 = "670fad41f57c13b71a6816765765a3dd";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "flask-0.10.1" = overridablePythonPackage {
    name = "flask-0.10.1";
    basename = "flask";
    version = "0.10.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/F/Flask/Flask-0.10.1.tar.gz";
        md5 = "378670fe456957eb3c27ddaef60b2b24";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."itsdangerous-0.23" self."werkzeug-0.9.4" self."jinja2-2.7.2" ];
  };
  
  "riak-pb-1.4.4.0" = overridablePythonPackage {
    name = "riak-pb-1.4.4.0";
    basename = "riak-pb";
    version = "1.4.4.0";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/r/riak_pb/riak_pb-1.4.4.0.tar.gz";
        md5 = "17d053dea083fdbaed1caaebed3461bd";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."protobuf-2.4.1" ];
  };
  
  "requests-2.2.1" = overridablePythonPackage {
    name = "requests-2.2.1";
    basename = "requests";
    version = "2.2.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/r/requests/requests-2.2.1.tar.gz";
        md5 = "ac27081135f58d1a43e4fb38258d6f4e";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "setproctitle-1.1.8" = overridablePythonPackage {
    name = "setproctitle-1.1.8";
    basename = "setproctitle";
    version = "1.1.8";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/s/setproctitle/setproctitle-1.1.8.tar.gz";
        md5 = "728f4c8c6031bbe56083a48594027edd";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "pylibmc-1.2.3" = overridablePythonPackage {
    name = "pylibmc-1.2.3";
    basename = "pylibmc";
    version = "1.2.3";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/pylibmc/pylibmc-1.2.3.tar.gz";
        md5 = "bfdcfef66a1bf260a65d2ffdcdd68466";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "anyjson-0.3.3" = overridablePythonPackage {
    name = "anyjson-0.3.3";
    basename = "anyjson";
    version = "0.3.3";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/a/anyjson/anyjson-0.3.3.tar.gz";
        md5 = "2ea28d6ec311aeeebaf993cb3008b27c";
    };

    buildInputs = [ self."nose-1.3.0" ];
    propagatedBuildInputs = [ ];
  };
  
  "lxml-3.3.2" = overridablePythonPackage {
    name = "lxml-3.3.2";
    basename = "lxml";
    version = "3.3.2";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/l/lxml/lxml-3.3.2.tar.gz";
        md5 = "a3ea7bf74b718ecb46d9fd5198eec92d";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "pygments-1.6" = overridablePythonPackage {
    name = "pygments-1.6";
    basename = "pygments";
    version = "1.6";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/P/Pygments/Pygments-1.6.tar.gz";
        md5 = "a18feedf6ffd0b0cc8c8b0fbdb2027b1";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "urllib3-1.7.1" = overridablePythonPackage {
    name = "urllib3-1.7.1";
    basename = "urllib3";
    version = "1.7.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/u/urllib3/urllib3-1.7.1.tar.gz";
        md5 = "8b05bb2081379fe3c332542aa7c172f3";
    };

    buildInputs = [ self."tornado-2.4.1" self."mock-1.0.1" self."coverage-3.6" self."nose-1.3.0" ];
    propagatedBuildInputs = [ ];
  };
  
  "thrift-0.9.1" = overridablePythonPackage {
    name = "thrift-0.9.1";
    basename = "thrift";
    version = "0.9.1";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/t/thrift/thrift-0.9.1.tar.gz";
        md5 = "8989a8a96b0e3a3380cfb89c44e172a6";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "django-1.5.5" = overridablePythonPackage {
    name = "django-1.5.5";
    basename = "django";
    version = "1.5.5";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/D/Django/Django-1.5.5.tar.gz";
        md5 = "e33355ee4bb2cbb4ab3954d3dff5eddd";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "jinja2-2.7.2" = overridablePythonPackage {
    name = "jinja2-2.7.2";
    basename = "jinja2";
    version = "2.7.2";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.7.2.tar.gz";
        md5 = "df1581455564e97010e38bc792012aa5";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."markupsafe-0.18" ];
  };
  
  "django-crispy-forms-1.2.8" = overridablePythonPackage {
    name = "django-crispy-forms-1.2.8";
    basename = "django-crispy-forms";
    version = "1.2.8";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/d/django-crispy-forms/django-crispy-forms-1.2.8.tar.gz";
        md5 = "ed73111103ddaa39b6617a41eaee5c7e";
    };

    buildInputs = [ self."django-1.5.5" ];
    propagatedBuildInputs = [ ];
  };
  
  "python-termstyle-0.1.10" = overridablePythonPackage {
    name = "python-termstyle-0.1.10";
    basename = "python-termstyle";
    version = "0.1.10";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/python-termstyle/python-termstyle-0.1.10.tar.gz";
        md5 = "1b227cebbeda209029252420af72e5c7";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."setuptools-2.2" ];
  };
  
  "billiard-2.7.3.34" = overridablePythonPackage {
    name = "billiard-2.7.3.34";
    basename = "billiard";
    version = "2.7.3.34";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/b/billiard/billiard-2.7.3.34.tar.gz";
        md5 = "9ecf0a3dbbd023e1fe9830b40d397d70";
    };

    buildInputs = [ self."mock-1.0.1" self."unittest2-0.5.1" self."nose-cover3-0.1.0" self."nose-1.3.0" ];
    propagatedBuildInputs = [ ];
  };
  
  "casscache-0.1.0" = overridablePythonPackage {
    name = "casscache-0.1.0";
    basename = "casscache";
    version = "0.1.0";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/c/casscache/casscache-0.1.0.tar.gz";
        md5 = "8b887eed2cd7efd3f9804476a6a2251b";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."cassandra-driver-1.0.1" ];
  };
  
  "setuptools-2.2" = overridablePythonPackage {
    name = "setuptools-2.2";
    basename = "setuptools";
    version = "2.2";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/s/setuptools/setuptools-2.2.tar.gz";
        md5 = "04a7664538957b832710653fd7d5b4e6";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "pynliner-0.5.0" = overridablePythonPackage {
    name = "pynliner-0.5.0";
    basename = "pynliner";
    version = "0.5.0";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/pynliner/pynliner-0.5.0.tar.gz";
        md5 = "26c8e836d722f7a5552593d482aac1ec";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."mock-1.0.1" self."beautifulsoup-3.2.1" self."cssutils-0.9.10" ];
  };
  
  "email-reply-parser-0.2.0" = overridablePythonPackage {
    name = "email-reply-parser-0.2.0";
    basename = "email-reply-parser";
    version = "0.2.0";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/e/email_reply_parser/email_reply_parser-0.2.0.tar.gz";
        md5 = "6fb93cf85eca7916b6e8db6cb67a8f53";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "sure-1.2.5" = overridablePythonPackage {
    name = "sure-1.2.5";
    basename = "sure";
    version = "1.2.5";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/s/sure/sure-1.2.5.tar.gz";
        md5 = "1470c08420681ca904bf306b1b3d250d";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ self."nose-1.3.0" self."rednose-0.4.1" ];
  };
  
  "python-dateutil-1.5" = overridablePythonPackage {
    name = "python-dateutil-1.5";
    basename = "python-dateutil";
    version = "1.5";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/python-dateutil/python-dateutil-1.5.tar.gz";
        md5 = "0dcb1de5e5cad69490a3b6ab63f0cfa5";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
  "pep8-1.4.6" = overridablePythonPackage {
    name = "pep8-1.4.6";
    basename = "pep8";
    version = "1.4.6";

    src = fetchurl {
        url = "https://pypi.python.org/packages/source/p/pep8/pep8-1.4.6.tar.gz";
        md5 = "a03bb494859e87b42601b61b1b043a0c";
    };

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  
})
