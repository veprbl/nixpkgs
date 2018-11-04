{ stdenv
, buildPythonPackage
, fetchPypi
, openssl
, cryptography_vectors
, darwin
, idna
, asn1crypto
, packaging
, six
, pythonOlder
, enum34
, ipaddress
, isPyPy
, cffi
, pytest
, pretend
, iso8601
, pytz
, hypothesis
, fetchpatch
}:

buildPythonPackage rec {
  # also bump cryptography_vectors
  pname = "cryptography";
  version = "2.3.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "8d10113ca826a4c29d5b85b2c4e045ffa8bad74fb525ee0eceb1d38d4c70dfd6";
  };

  outputs = [ "out" "dev" ];

  buildInputs = [ openssl cryptography_vectors ]
             ++ stdenv.lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security;
  propagatedBuildInputs = [
    idna
    asn1crypto
    packaging
    six
  ] ++ stdenv.lib.optional (pythonOlder "3.4") enum34
  ++ stdenv.lib.optional (pythonOlder "3.3") ipaddress
  ++ stdenv.lib.optional (!isPyPy) cffi;

  checkInputs = [
    pytest
    pretend
    iso8601
    pytz
    hypothesis
  ];

  patches = [
    (fetchpatch {
      url = https://github.com/pyca/cryptography/commit/0322962e143798fa5228f4505eeb606cdf773b87.patch;
      sha256 = "00c42ql4k8wk924i4pccqc6nkm0c58l7j3vf2fzlawdanyz1s9sb";
    })
  ];

  # The test assumes that if we're on Sierra or higher, that we use `getentropy`, but for binary
  # compatibility with pre-Sierra for binary caches, we hide that symbol so the library doesn't
  # use it. This boils down to them checking compatibility with `getentropy` in two different places,
  # so let's neuter the second test.
  postPatch = ''
    substituteInPlace ./tests/hazmat/backends/test_openssl.py --replace '"16.0"' '"99.0"'
  '';

  # IOKit's dependencies are inconsistent between OSX versions, so this is the best we
  # can do until nix 1.11's release
  __impureHostDeps = [ "/usr/lib" ];
}
