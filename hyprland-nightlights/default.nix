{
  pkgs,
  version,
}:
pkgs.callPackage ../builder.nix {
  pname = "hyprland-nightlights";

  inherit version;

  src = ./.;

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    hyprsunset
  ];
}
