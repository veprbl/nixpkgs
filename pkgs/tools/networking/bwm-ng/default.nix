{ stdenv, fetchFromGitHub, ncurses, autoreconfHook }:

let
  version = "0.6.2";
in
stdenv.mkDerivation rec {
  name = "bwm-ng-${version}";

  src = fetchFromGitHub {
    owner = "vgropp";
    repo = "bwm-ng";
    rev = "v${version}";
    sha256 = "0k906wb4pw3dcqpcwnni78lahzi3bva483f8c17sjykic7as4y5n";
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ ncurses ];

  meta = with stdenv.lib; {
    description = "A small and simple console-based live network and disk io bandwidth monitor";
    homepage = http://www.gropp.org/?id=projects&sub=bwm-ng;
    license = licenses.gpl2;
    platforms = platforms.unix;

    longDescription = ''
        Features

            supports /proc/net/dev, netstat, getifaddr, sysctl, kstat, /proc/diskstats /proc/partitions, IOKit, devstat and libstatgrab
            unlimited number of interfaces/devices supported
            interfaces/devices are added or removed dynamically from list
            white-/blacklist of interfaces/devices
            output of KB/s, Kb/s, packets, errors, average, max and total sum
            output in curses, plain console, CSV or HTML
            configfile

        Short list of changes since 0.5 (for full list read changelog):

            curses2 output, a nice bar chart
            disk input for bsd/macosx/linux/solaris
            win32 network bandwidth support
            moved to autotools
            alot fixes

        Info
        This was influenced by the old bwm util written by Barney (barney@freewill.tzo.com) which had some issues with faster interfaces and was very simple. Since i had almost all code done anyway for other projects, i decided to create my own version.

        I actually don't know if netstat input is useful at all. I saw this elsewhere, so i added it. Its target is "netstat 1.42 (2001-04-15)" linux or Free/Open/netBSD. If there are other formats i would be happy to add them.

        (from homepage)
    '';
  };
}
