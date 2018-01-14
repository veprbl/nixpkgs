{ stdenv, fetchFromGitHubWithUpdater, m4, makeWrapper, libbsd, perl, SysCPU }:

stdenv.mkDerivation rec {
  name = "csmith-${version}";
  version = "2.3.0";

  src = fetchFromGitHubWithUpdater {
    owner = "csmith-project";
    repo = "csmith";
    rev = "csmith-${version}";
    sha256 = "0dlwv3xip2jchllm7sc0x7hxvggcprjqh0irfc2rch912h1c6xgv";
  };

  nativeBuildInputs = [ m4 makeWrapper ];
  buildInputs = [ libbsd perl SysCPU ];

  postInstall = ''
    substituteInPlace $out/bin/compiler_test.pl \
      --replace '$CSMITH_HOME/runtime' $out/include/${name} \
      --replace ' ''${CSMITH_HOME}/runtime' " $out/include/${name}" \
      --replace '$CSMITH_HOME/src/csmith' $out/bin/csmith

    substituteInPlace $out/bin/launchn.pl \
      --replace '../compiler_test.pl' $out/bin/compiler_test.pl \
      --replace '../$CONFIG_FILE' '$CONFIG_FILE'

    wrapProgram $out/bin/launchn.pl \
      --prefix PERL5LIB : "$PERL5LIB"

    mkdir -p $out/share/csmith
    mv $out/bin/compiler_test.in $out/share/csmith/
  '';

  enableParallelBuilding = true;

  passthru.updateScript = src.updateScript;

  meta = with stdenv.lib; {
    description = "A random generator of C programs";
    homepage = https://embed.cs.utah.edu/csmith;
    # Officially, the license is this: https://github.com/csmith-project/csmith/blob/master/COPYING
    license = licenses.bsd2;
    longDescription = ''
      Csmith is a tool that can generate random C programs that statically and
      dynamically conform to the C99 standard. It is useful for stress-testing
      compilers, static analyzers, and other tools that process C code.
      Csmith has found bugs in every tool that it has tested, and has been used
      to find and report more than 400 previously unknown compiler bugs.
    '';
    maintainers = [ maintainers.dtzWill ];
    platforms = platforms.all;
  };
}
