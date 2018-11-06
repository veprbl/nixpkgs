{ stdenv, fetchurl
, virtualbox }:

with stdenv.lib;

fetchurl rec {
  name = "Oracle_VM_VirtualBox_Extension_Pack-${virtualbox.version}.vbox-extpack";
  url = "https://download.virtualbox.org/virtualbox/${virtualbox.version}/${name}";
  sha256 = "0yb2pnic26pj22q0wp678cqr5khzmdds7zzdd67as09fsapkypc1";

  meta = {
    description = "Oracle Extension pack for VirtualBox";
    license = licenses.virtualbox-puel;
    homepage = https://www.virtualbox.org/;
    maintainers = with maintainers; [ flokli sander cdepillabout ];
    platforms = [ "x86_64-linux" "i686-linux" ];
  };
}
