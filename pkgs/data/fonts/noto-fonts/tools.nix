{ fetchFromGitHub, pythonPackages, lib }:

pythonPackages.buildPythonPackage rec {
  version = "2019-02-21";
  name = "nototools-${version}";

  src = fetchFromGitHub {
    owner = "googlei18n";
    repo = "nototools";
    rev = "bb309e87d273b3afd89b6c66c43b332899e74f5d";
    sha256 = "1gz9kmzrgayxvxn3vj8j6dqp66g1angmbq2yyh5r9x6g9p6k2dy8";
  };

  propagatedBuildInputs = with pythonPackages; [
    fonttools numpy
    # requirements.txt
    # booleanOperations==0.7.0
    # defcon==0.3.1
    # fonttools>=3.36.0
    # Pillow==4.0.0
    pillow
    # pyclipper==1.0.6
    # ufoLib==2.0.0
    # scour==0.37
    scour
  ];

  postPatch = ''
    sed -ie "s^join(_DATA_DIR_PATH,^join(\"$out/third_party/ucd\",^" nototools/unicode_data.py
  '';

  postInstall = ''
    cp -r third_party $out
  '';

  disabled = pythonPackages.isPy3k;

  meta = {
    description = "Noto fonts support tools and scripts plus web site generation";
    license = lib.licenses.asl20;
    homepage = https://github.com/googlei18n/nototools;
    platforms = lib.platforms.unix;
  };
}
