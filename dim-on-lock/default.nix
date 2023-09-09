{ pkgs, version }:

pkgs.callPackage ../builder.nix {
  pname = "dim-on-lock";

  inherit version;

  src = ./.;

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    brightnessctl
  ];
}

