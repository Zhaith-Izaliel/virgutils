{ pkgs, version }:

pkgs.callPackage ../builder.nix {
  pname = "dunstbar";

  inherit version;

  src = ./.;

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    dunst
    jq
  ];
}

