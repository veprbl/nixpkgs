{ qtModule, stdenv, qtbase }:

qtModule {
  name = "qtnetworkauth";
  qtInputs = [ qtbase ];
  outputs = [ "out" "dev" "bin" ];
}
