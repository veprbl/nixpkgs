{stdenv, fetchurl, lib}:

with lib;

let extpackRev = "124319";
    version = "5.2.18";
in
fetchurl rec {
  name = "Oracle_VM_VirtualBox_Extension_Pack-${version}-${toString extpackRev}.vbox-extpack";
  url = "https://download.virtualbox.org/virtualbox/${version}/${name}";
  sha256 = "0s3gh2n2qjhy8xbdppzkphjd8p5nirh6qmwhnx71yx022p3l7jry";

  meta = {
    description = "Oracle Extension pack for VirtualBox";
    license = licenses.virtualbox-puel;
    homepage = https://www.virtualbox.org/;
    maintainers = with maintainers; [ flokli sander cdepillabout ];
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
}
