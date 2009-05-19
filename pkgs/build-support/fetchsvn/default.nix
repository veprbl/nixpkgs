{stdenv, subversion, sshSupport ? false, openssh ? null}: 
{url, rev ? "HEAD", md5 ? "", sha256 ? ""}:

stdenv.mkDerivation {
  name = "svn-export";
  builder = ./builder.sh;
  buildInputs = [subversion];

  outputHashAlgo = if sha256 == "" then "md5" else "sha256";
  outputHashMode = "recursive";
  outputHash = if sha256 == "" then md5 else sha256;
  
  inherit url rev sshSupport openssh;

  impureEnvVars = [
    # We borrow these environment variables from the caller to allow
    # easy proxy configuration.  This is impure, but a fixed-output
    # derivation like fetchurl is allowed to do so since its result is
    # by definition pure.
    "http_proxy" "https_proxy" "ftp_proxy" "all_proxy" "no_proxy"
    ];
}
