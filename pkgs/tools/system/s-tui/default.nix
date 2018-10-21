{ stdenv, pythonPackages, fetchpatch }:

pythonPackages.buildPythonPackage rec {
  name = "${pname}-${version}";
  pname = "s-tui";
  version = "0.8.2";

  src = pythonPackages.fetchPypi {
    inherit pname version;
    sha256 = "18bn0bpnrljx11gj95m2x5hlsnb8jkivlm6b1xx035ldgj1svgzh";
  };

  patches = [
    (fetchpatch {
      name = "temp-thresholds.patch";
      url = "https://github.com/amanusk/s-tui/commit/265840bf0324da0cd5eef8a19e125c5e5cda12e9.patch";
      sha256 = "0zyzm60srq8111jn4h8la6yx1djfnihgn5y2sd763hlkiadf162i";
    })
  ];

  propagatedBuildInputs = with pythonPackages; [
    urwid
    psutil
  ];

  meta = with stdenv.lib; {
    homepage = https://amanusk.github.io/s-tui/;
    description = "Stress-Terminal UI monitoring tool";
    license = licenses.gpl2;
    maintainers = with maintainers; [ infinisil ];
  };
}
