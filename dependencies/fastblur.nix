{
  stdenv,
  input,
}:
stdenv.mkDerivation {
  pname = "fastblur";

  version = input.shortRev;

  src = input;

  installPhase = ''
    install -Dm555 fastblur $out/bin/fastblur
  '';
}
