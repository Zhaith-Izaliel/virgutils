{ pkgs, version }:

pkgs.callPackage ../builder.nix {
  pname = "start-vm";

  inherit version;

  src = ./.;

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    virt-manager
    pstree
    libnotify
    looking-glass-client
  ];
}

