{ stdenv, fetchgit, releaseTools, maven}:

releaseTools.mvnBuild rec {
  name = "seyren-9463b857de";

  src = fetchgit {
    url = https://github.com/scobal/seyren.git;
    rev = "9463b857de645b9bebed079933477e7d35240044";
    sha256 = "0ac25gjjccfxx92cvkmafsmwmhcxi16hnm7q9cam09cv7b6pm962";
  };

  buildInputs = [ maven ];

  meta = {
    description = "An enterprise-class open source distributed monitoring solution";
    homepage = http://www.zabbix.com/;
    license = "GPL";
    maintainers = [ stdenv.lib.maintainers.eelco ];
    platforms = stdenv.lib.platforms.linux;
  };
}
