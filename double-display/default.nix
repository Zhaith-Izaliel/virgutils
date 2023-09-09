{ pkgs, version }:

pkgs.callPackage ../builder.nix {
  pname = "double-display";
  inherit version;

  src = ./.;

  buildInputs = [
    pkgs.bash
  ];

  paths = [
    pkgs.wlr-randr
  ];
}

