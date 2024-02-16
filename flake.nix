{
  description = "Virgutils, multiple utils used in Zhaith Izaliel's system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    hyprwm-contrib.url = "github:hyprwm/contrib";
    flake-utils.url = "github:numtide/flake-utils";
    fast-blur = {
      url = "github:bfraboni/FastGaussianBlur";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    hyprwm-contrib,
    fast-blur,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system:
      with import nixpkgs {inherit system;}; let
        version = "1.10.1";
        fast-blur-package = pkgs.callPackage ./dependencies/fastblur.nix {input = fast-blur;};
      in rec {
        devShells = {
          workspaceShell = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              bashInteractive
              brightnessctl
              dunst
              libnotify
              looking-glass-client
              virt-manager
              wireplumber
              gawk
              bc
              gnused
              wlogout
              imagemagick
              hyprwm-contrib.packages.${system}.grimblast
              bluez
              gnugrep
              gnused
              coreutils
              wlr-randr
              power-profiles-daemon
              node2nix
              fast-blur-package
            ];
          };
          default = devShells.workspaceShell;
        };

        packages = {
          dim-on-lock = pkgs.callPackage ./dim-on-lock {inherit version;};
          double-display = pkgs.callPackage ./double-display {inherit version;};
          nix-npm-install = pkgs.callPackage ./nix-npm-install {inherit version;};
          power-management = pkgs.callPackage ./power-management {inherit version;};
          start-vm = pkgs.callPackage ./start-vm {inherit version;};
          toggle-bluetooth = pkgs.callPackage ./toggle-bluetooth {inherit version;};
          volume-brightness = pkgs.callPackage ./volume-brightness {inherit version;};
          wlogout-blur = pkgs.callPackage ./wlogout-blur {
            grimblast = hyprwm-contrib.packages.${system}.grimblast;
            fastblur = fast-blur-package;
            inherit version;
          };
          screenshot = pkgs.callPackage ./screenshot {
            grimblast = hyprwm-contrib.packages.${system}.grimblast;
            inherit version;
          };
          dunstbar = pkgs.callPackage ./dunstbar {inherit version;};
          power-profilesbar = pkgs.callPackage ./power-profilesbar {inherit version;};
        };

        overlays.default = final: prev: packages;
      });
}
