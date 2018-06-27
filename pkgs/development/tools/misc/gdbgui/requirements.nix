# generated using pypi2nix tool (version: 1.8.1)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -V 2.7 -r requirements.txt
#

{ pkgs ? import <nixpkgs> {}
}:

let

  inherit (pkgs) makeWrapper;
  inherit (pkgs.stdenv.lib) fix' extends inNixShell;

  pythonPackages =
  import "${toString pkgs.path}/pkgs/top-level/python-packages.nix" {
    inherit pkgs;
    inherit (pkgs) stdenv;
    python = pkgs.python27Full;
    # patching pip so it does not try to remove files when running nix-shell
    overrides =
      self: super: {
        bootstrapped-pip = super.bootstrapped-pip.overrideDerivation (old: {
          patchPhase = old.patchPhase + ''
            sed -i               -e "s|paths_to_remove.remove(auto_confirm)|#paths_to_remove.remove(auto_confirm)|"                -e "s|self.uninstalled = paths_to_remove|#self.uninstalled = paths_to_remove|"                  $out/${pkgs.python35.sitePackages}/pip/req/req_install.py
          '';
        });
      };
  };

  commonBuildInputs = [];
  commonDoCheck = false;

  withPackages = pkgs':
    let
      pkgs = builtins.removeAttrs pkgs' ["__unfix__"];
      interpreter = pythonPackages.buildPythonPackage {
        name = "python27Full-interpreter";
        buildInputs = [ makeWrapper ] ++ (builtins.attrValues pkgs);
        buildCommand = ''
          mkdir -p $out/bin
          ln -s ${pythonPackages.python.interpreter}               $out/bin/${pythonPackages.python.executable}
          for dep in ${builtins.concatStringsSep " "               (builtins.attrValues pkgs)}; do
            if [ -d "$dep/bin" ]; then
              for prog in "$dep/bin/"*; do
                if [ -f $prog ]; then
                  ln -s $prog $out/bin/`basename $prog`
                fi
              done
            fi
          done
          for prog in "$out/bin/"*; do
            wrapProgram "$prog" --prefix PYTHONPATH : "$PYTHONPATH"
          done
          pushd $out/bin
          ln -s ${pythonPackages.python.executable} python
          ln -s ${pythonPackages.python.executable}               python2
          popd
        '';
        passthru.interpreter = pythonPackages.python;
      };
    in {
      __old = pythonPackages;
      inherit interpreter;
      mkDerivation = pythonPackages.buildPythonPackage;
      packages = pkgs;
      overrideDerivation = drv: f:
        pythonPackages.buildPythonPackage (drv.drvAttrs // f drv.drvAttrs //                                            { meta = drv.meta; });
      withPackages = pkgs'':
        withPackages (pkgs // pkgs'');
    };

  python = withPackages {};

  generated = self: {

    "Flask" = python.mkDerivation {
      name = "Flask-0.12.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/1b/72/ffc594a6832337ace475f939e61c34a44cbb150cde9589f98c482b407dd8/Flask-0.12.4.tar.gz"; sha256 = "2ea22336f6d388b4b242bc3abf8a01244a8aa3e236e7407469ef78c16ba355dd"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Jinja2"
      self."Werkzeug"
      self."click"
      self."itsdangerous"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/pallets/flask/";
        license = licenses.bsdOriginal;
        description = "A microframework based on Werkzeug, Jinja2 and good intentions";
      };
    };



    "Flask-Compress" = python.mkDerivation {
      name = "Flask-Compress-1.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0e/2a/378bd072928f6d92fd8c417d66b00c757dc361c0405a46a0134de6fd323d/Flask-Compress-1.4.0.tar.gz"; sha256 = "468693f4ddd11ac6a41bca4eb5f94b071b763256d54136f77957cfee635badb3"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Flask"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://libwilliam.github.io/flask-compress/";
        license = licenses.mit;
        description = "Compress responses in your Flask app with gzip.";
      };
    };



    "Flask-SocketIO" = python.mkDerivation {
      name = "Flask-SocketIO-2.9.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/5d/94/6f55de2fd72f1d7f7eb17cd6045a50581e7c66d53580fc93fd607a5cd630/Flask-SocketIO-2.9.6.tar.gz"; sha256 = "f49edfd3a44458fbb9f7a04a57069ffc0c37f000495194f943a25d370436bb69"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Flask"
      self."python-socketio"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/miguelgrinberg/Flask-SocketIO/";
        license = licenses.mit;
        description = "Socket.IO integration for Flask applications";
      };
    };



    "Jinja2" = python.mkDerivation {
      name = "Jinja2-2.10";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/56/e6/332789f295cf22308386cf5bbd1f4e00ed11484299c5d7383378cf48ba47/Jinja2-2.10.tar.gz"; sha256 = "f84be1bb0040caca4cea721fcbbbbd61f9be9464ca236387158b0feea01914a4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."MarkupSafe"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://jinja.pocoo.org/";
        license = licenses.bsdOriginal;
        description = "A small but fast and easy to use stand-alone template engine written in pure python.";
      };
    };



    "MarkupSafe" = python.mkDerivation {
      name = "MarkupSafe-1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4d/de/32d741db316d8fdb7680822dd37001ef7a448255de9699ab4bfcbdf4172b/MarkupSafe-1.0.tar.gz"; sha256 = "a6be69091dac236ea9c6bc7d012beab42010fa914c459791d627dad4910eb665"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/pallets/markupsafe";
        license = licenses.bsdOriginal;
        description = "Implements a XML/HTML/XHTML Markup safe string for Python";
      };
    };



    "Pygments" = python.mkDerivation {
      name = "Pygments-2.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/71/2a/2e4e77803a8bd6408a2903340ac498cb0a2181811af7c9ec92cb70b0308a/Pygments-2.2.0.tar.gz"; sha256 = "dbae1046def0efb574852fab9e90209b23f556367b5a320c0bcb871c77c3e8cc"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pygments.org/";
        license = licenses.bsdOriginal;
        description = "Pygments is a syntax highlighting package written in Python.";
      };
    };



    "Werkzeug" = python.mkDerivation {
      name = "Werkzeug-0.14.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9f/08/a3bb1c045ec602dc680906fc0261c267bed6b3bb4609430aff92c3888ec8/Werkzeug-0.14.1.tar.gz"; sha256 = "c3fd7a7d41976d9f44db327260e263132466836cef6f91512889ed60ad26557c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://www.palletsprojects.org/p/werkzeug/";
        license = licenses.bsdOriginal;
        description = "The comprehensive WSGI web application library.";
      };
    };



    "click" = python.mkDerivation {
      name = "click-6.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/95/d9/c3336b6b5711c3ab9d1d3a80f1a3e2afeb9d8c02a7166462f6cc96570897/click-6.7.tar.gz"; sha256 = "f15516df478d5a56180fbf80e68f206010e6d160fc39fa508b65e035fd75130b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/mitsuhiko/click";
        license = licenses.bsdOriginal;
        description = "A simple wrapper around optparse for powerful command line utilities.";
      };
    };



    "gevent" = python.mkDerivation {
      name = "gevent-1.3.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f8/85/f92a8f43c9f15ffad49d743d929863a042ce3e8de5746c63bb4d6ce51a02/gevent-1.3.4.tar.gz"; sha256 = "53c4dc705886d028f5d81e698b1d1479994a421498cd6529cb9711b5e2a84f74"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."greenlet"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.gevent.org/";
        license = licenses.mit;
        description = "Coroutine-based network library";
      };
    };



    "greenlet" = python.mkDerivation {
      name = "greenlet-0.4.13";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/13/de/ba92335e9e76040ca7274224942282a80d54f85e342a5e33c5277c7f87eb/greenlet-0.4.13.tar.gz"; sha256 = "0fef83d43bf87a5196c91e73cb9772f945a4caaff91242766c5916d1dd1381e4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/python-greenlet/greenlet";
        license = licenses.mit;
        description = "Lightweight in-process concurrent programming";
      };
    };



    "itsdangerous" = python.mkDerivation {
      name = "itsdangerous-0.24";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/dc/b4/a60bcdba945c00f6d608d8975131ab3f25b22f2bcfe1dab221165194b2d4/itsdangerous-0.24.tar.gz"; sha256 = "cbb3fcf8d3e33df861709ecaf89d9e6629cff0a217bc2848f1b41cd30d360519"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/mitsuhiko/itsdangerous";
        license = licenses.bsdOriginal;
        description = "Various helpers to pass trusted data to untrusted environments and back.";
      };
    };



    "pygdbmi" = python.mkDerivation {
      name = "pygdbmi-0.8.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4e/34/a8c86d85e0d3d8df2c289657a55c19408dbdbf0b1468859e7f1a745ae8ff/pygdbmi-0.8.2.0.tar.gz"; sha256 = "47cece65808ca42edf6966ac48e2aedca7ae1c675c4d2f0d001c7f3a7fa245fe"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/cs01/pygdbmi";
        license = licenses.mit;
        description = "Parse gdb machine interface output with Python";
      };
    };



    "python-engineio" = python.mkDerivation {
      name = "python-engineio-2.1.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ae/28/11a0c38bf1bdf3d25901b9120dc554fae90647162b48997644cfa026d518/python-engineio-2.1.1.tar.gz"; sha256 = "68307a9cc24392d7a581460226fd0246f92b1923722c37a4af83c374d94b2c8a"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/miguelgrinberg/python-engineio/";
        license = licenses.mit;
        description = "Engine.IO server";
      };
    };



    "python-socketio" = python.mkDerivation {
      name = "python-socketio-1.9.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/37/94/aab2fc3c2f2a5b974b676d8b47f0b630d7dd406aa28437e38ed47250af5c/python-socketio-1.9.0.tar.gz"; sha256 = "71feb10a1b7b410d8f86bbcb0f589c75a32504a01259ed89aa1d7d5dae9190cc"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."python-engineio"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/miguelgrinberg/python-socketio/";
        license = licenses.mit;
        description = "Socket.IO server";
      };
    };



    "six" = python.mkDerivation {
      name = "six-1.11.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"; sha256 = "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pypi.python.org/pypi/six/";
        license = licenses.mit;
        description = "Python 2 and 3 compatibility utilities";
      };
    };

  };
  localOverridesFile = ./requirements_override.nix;
  overrides = import localOverridesFile { inherit pkgs python; };
  commonOverrides = [

  ];
  allOverrides =
    (if (builtins.pathExists localOverridesFile)
     then [overrides] else [] ) ++ commonOverrides;

in python.withPackages
   (fix' (pkgs.lib.fold
            extends
            generated
            allOverrides
         )
   )