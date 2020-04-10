{ runCommandNoCC, texlive }:

{
  # https://github.com/NixOS/nixpkgs/issues/75070
  dvisvgm = runCommandNoCC "texlive-test-dvisvgm" {
    buildInputs = [ texlive.combined.scheme-medium ];
    input = builtins.toFile "dvipng-sample.tex" ''
      \documentclass{article}
      \begin{document}
        mwe
      \end{document}
    '';
  } ''
    cp "$input" ./document.tex

    latex document.tex
    dvisvgm document.dvi -n -o document_dvi.svg
    cat document_dvi.svg

    pdflatex document.tex
    dvisvgm -P document.pdf -n -o document_pdf.svg
    cat document_pdf.svg

    touch "$out"
  '';
}
