{ stdenv, lib, fetchurl, python}:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "manta";
  version = "1.4.0";

  src = fetchurl {
    url = "https://github.com/Illumina/manta/releases/download/v${version}/manta-${version}.centos6_x86_64.tar.bz2";
    sha256 = "0hds1a70z4vya9wbcfkxdipms5i1qf8nix96i0a2lfjh1l77qm79";
  };

  phases = "installPhase";

  installPhase = ''
    mkdir -p $out
    tar xvjf $src
    ls -ahl
    pwd
    cd manta-${version}.centos6_x86_64
    cp -R bin lib libexec share $out/
  '';

  meta = with stdenv.lib; {
    description = "Manta calls structural variants (SVs) and indels from mapped paired-end sequencing reads";
    license = licenses.gpl3;
    platforms = platforms.linux;
    homepage = https://github.com/Illumina/manta;
    maintainers = [ ];
  };
}
