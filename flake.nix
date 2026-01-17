{
  description = "Virgutils, multiple utils used in Zhaith Izaliel's system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = inputs @ {flake-parts, ...}: let
    version = "1.19.0";
  in
    flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      imports = [
        flake-parts.flakeModules.easyOverlay
      ];

      systems = ["x86_64-linux" "aarch64-linux"];

      perSystem = {
        config,
        pkgs,
        ...
      }: {
        overlayAttrs = config.packages;

        devShells = {
          # nix develop
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              brightnessctl
              libnotify
              coreutils
              node2nix
            ];
          };
        };

        packages = {
          dim-on-lock = pkgs.callPackage ./dim-on-lock {inherit version;};
          nix-npm-install = pkgs.callPackage ./nix-npm-install {inherit version;};
          power-management = pkgs.callPackage ./power-management {inherit version;};
        };
      };
    });
}
