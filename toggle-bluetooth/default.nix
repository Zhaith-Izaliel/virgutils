{ pkgs, version }:

pkgs.callPackage ../builder.nix {
  pname = "toggle-bluetooth";

  inherit version;

  src = ./.;

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    bluez
    bash
    gnugrep
  ];
}

