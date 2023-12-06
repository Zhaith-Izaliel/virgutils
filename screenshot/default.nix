{ pkgs, version, grimblast }:

pkgs.callPackage ../builder.nix {
  pname = "screenshot";

  inherit version;

  src = ./.;

  buildInputs = with pkgs; [
    bash
  ];

  paths = [
    grimblast
  ];
}

