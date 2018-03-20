
{
  busybox = import <nix/fetchurl.nix> {
    url = https://wdtz.org/files/nr8xhx04mx7m2j8gnyif00vbk8jw3zh4-stdenv-bootstrap-tools-i686-unknown-linux-musl/on-server/busybox;
    sha256 = "16lzrwwvdk6q3g08gs45pldz0rh6xpln2343xr444960h6wqxl6v";
    executable = true;
  };
  bootstrapTools = import <nix/fetchurl.nix> {
    url = https://wdtz.org/files/nr8xhx04mx7m2j8gnyif00vbk8jw3zh4-stdenv-bootstrap-tools-i686-unknown-linux-musl/on-server/bootstrap-tools.tar.xz;
    sha256 = "0ly0wj8wzbikn2j8sn727vikk90bq36drh98qvfx1kkh5k5azm3j";
  };
}
