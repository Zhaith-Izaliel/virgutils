{
  pkgs,
  version,
}:
pkgs.callPackage ../builder.nix {
  pname = "screenshot";

  inherit version;

  src = ./.;

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    grimblast
  ];
}
