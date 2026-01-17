{
  pkgs,
  version,
}:
pkgs.callPackage ../builder.nix {
  pname = "power-management";

  inherit version;

  src = ./.;

  buildInputs = with pkgs; [
    bash
  ];

  paths = with pkgs; [
    libnotify
    sudo
    coreutils
  ];
}
