{
  description = "Virgutils, multiple utils used in Zhaith Izaliel's system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      version = "1.20.0";
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [
          flake-parts.flakeModules.easyOverlay
        ];

        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        perSystem =
          {
            config,
            pkgs,
            ...
          }:
          {
            overlayAttrs = config.packages;

            devShells = {
              # nix develop
              default = pkgs.mkShell {
                nativeBuildInputs = with pkgs; [
                  brightnessctl
                  libnotify
                  coreutils
                ];
              };
            };

            packages = {
              dim-on-lock = pkgs.callPackage ./dim-on-lock { inherit version; };
              power-management = pkgs.callPackage ./power-management { inherit version; };
            };
          };
      }
    );
}
