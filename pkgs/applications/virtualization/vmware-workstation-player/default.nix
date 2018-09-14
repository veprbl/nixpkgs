{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "vmware-workstation-player-${version}";
  version = "14.1.3";

  src = fetchurl {
    url = "https://download3.vmware.com/software/wkst/file/VMware-Workstation-Full-${version}-9474260.x86_64.bundle";
    sha256 = "0wq3br5yiwa18js9vc0swbqqdwc2iyydb07x2hjcfbqzdsnjil99";
  };

  unpackPhase = ''
    ${stdenv.shell} ${src} --extract .
  '';

  buildPhase = ''
  '';

  meta = with stdenv.lib; {
    description = ''
      The industry standard for running multiple operating systems as virtual machines on a single Linux PC
    '';
    homepage = "https://www.vmware.com/products/workstation-player.html";
    platforms = platforms.linux; # Restrict to x86_64?
    license = licenses.unfree;
    maintainers = with maintainers; [
      eadwu
    ];
  };
}
