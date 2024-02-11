{
  stdenv,
  input,
}:
stdenv.mkDerivation {
  pname = "fastblur";

  version = input.shortRev;

  src = input;
}
