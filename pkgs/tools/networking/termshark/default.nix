{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "termshark";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "gcla";
    repo = "termshark";
    rev = "v${version}";
    sha256 = "1h9wysvd7i4vzn9qyswrmckmshxmh24ypvca98balkyhsxjwlb6j";
  };

  modSha256 = "09mbjbk5wa18z4xis5b2v2v0b04mf4d896yp88vcj8d8hsmbmc6g";

  subPackages = [ "." ];

  meta = with stdenv.lib; {
    homepage = https://termshark.io/;
    description = "A terminal UI for tshark, inspired by Wireshark";
    platforms = platforms.linux;
    license = licenses.mit;
    maintainers = [ maintainers.winpat ];
  };
}
