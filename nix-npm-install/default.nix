{ pkgs, version }:

pkgs.callPackage ../builder.nix {
  pname = "nix-npm-install";
  inherit version;

  src = ./.;

  buildInputs = with pkgs; [
    bash
    nodejs
  ];

  paths = with pkgs; [
    nodePackages.node2nix
  ];
}

