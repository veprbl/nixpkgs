{ lib, fetchFromGitHub, fetchpatch
, python3, xdg_utils
}:

python3.pkgs.buildPythonApplication rec {
  pname = "papis";
  version = "0.8.2";

  # Missing tests on Pypi
  src = fetchFromGitHub {
    owner = "papis";
    repo = pname;
    #rev = "v${version}";
    rev = "3ffc41a12f2175abbecab64d051e971146ac7bc8";
    sha256 = "1y78j3b4fpicg6wvyqxg7ihf9hpz5y2n0v8bdwmby5i5z500mbdy";
  };

  propagatedBuildInputs = with python3.pkgs; [
    requests filetype pyparsing configparser arxiv2bib
    pyyaml chardet beautifulsoup4 colorama bibtexparser
    pylibgen click python-slugify habanero isbnlib
    prompt_toolkit pygments
    # optional dependencies
    jinja2 whoosh
  ];

  checkInputs = (with python3.pkgs; [
    pytest
  ]) ++ [
    xdg_utils
  ];

  patches = [
    (fetchpatch {
      url = "https://github.com/papis/papis/pull/145.patch";
      sha256 = "13y0rr31zww7zcvx33wm4js45jlq5rcmrpcnhd0gzv847f7w1ax8";
    })
  ];

  # most of the downloader tests and 4 other tests require a network connection
  checkPhase = ''
    HOME=$(mktemp -d) pytest papis tests --ignore tests/downloaders \
      -k "not test_get_data and not test_doi_to_data and not test_general and not get_document_url"
  '';

  postInstall = ''
    install -D "scripts/shell_completion/click/papis.zsh" $out/share/zsh/site-functions/_papis
  '';

  meta = {
    description = "Powerful command-line document and bibliography manager";
    homepage = http://papis.readthedocs.io/en/latest/;
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.nico202 ];
  };
}
