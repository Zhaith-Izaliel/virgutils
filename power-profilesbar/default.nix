{ pkgs, version }:

pkgs.callPackage ../builder.nix {
  pname = "power-profilesbar";

  inherit version;

  src = ./.;

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    power-profiles-daemon
    jq
    coreutils
  ];
}

