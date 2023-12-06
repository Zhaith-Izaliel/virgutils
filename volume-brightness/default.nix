{ pkgs, version }:

pkgs.callPackage ../builder.nix {
  pname = "volume-brightness";

  inherit version;

  src = ./.;

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    brightnessctl
    gawk
    wireplumber
    bc
    dunst
    gnused
  ];
}

