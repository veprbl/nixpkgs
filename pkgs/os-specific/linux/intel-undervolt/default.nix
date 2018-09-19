{ stdenv, fetchFromGitHub
  , systemd, pkgconfig }:

stdenv.mkDerivation rec {
  name = "intel-undervolt-${version}";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "kitsunyan";
    repo = "intel-undervolt";
    rev = version;
    sha256 = "12i9hyrzw2wllqyha7pqyxrbs5j5hhx7m15jjc4jjhlil4njmf1b";
  };

  prePatch = ''
    sed -i "s@DESTDIR=@\0$out@" Makefile
  '';

  nativeBuildInputs = [
    systemd
    pkgconfig
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv intel-undervolt $out/bin

    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = ''
      A tool for undervolting Haswell and newer Intel CPUs using MSR.
    '';
    longDescription = ''
      intel-undervolt is a tool for undervolting Haswell and newer Intel CPUs using MSR.

      This tool also allow to alter power limits and temperature limit using MSR and
      MCHBAR registers.
    '';
    homepage = "https://github.com/kitsunyan/intel-undervolt";
    platforms = [ "x86_64-linux" ];
    license = licenses.gpl3;
    maintainers = with maintainers; [
      eadwu
    ];
  };
}
