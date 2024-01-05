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
  };

  outputs = { nixpkgs, flake-utils, hyprwm-contrib, ... }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    version  = "1.4.1";
  in
  with import nixpkgs { inherit system; };
  rec {
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
          recode
        ];
      };
      default = devShells.workspaceShell;
    };

    packages = {
      dim-on-lock = pkgs.callPackage ./dim-on-lock { inherit version; };
      double-display = pkgs.callPackage ./double-display { inherit version; };
      nix-npm-install = pkgs.callPackage ./nix-npm-install { inherit version; };
      power-management = pkgs.callPackage ./power-management { inherit version; };
      start-vm = pkgs.callPackage ./start-vm { inherit version; };
      toggle-bluetooth = pkgs.callPackage ./toggle-bluetooth { inherit version; };
      volume-brightness = pkgs.callPackage ./volume-brightness { inherit version; };
      wlogout-blur = pkgs.callPackage ./wlogout-blur {
        grimblast = hyprwm-contrib.packages.${system}.grimblast;
        inherit version;
      };
      screenshot = pkgs.callPackage ./screenshot {
        grimblast = hyprwm-contrib.packages.${system}.grimblast;
        inherit version;
      };
      dunstbar = pkgs.callPackage ./dunstbar { inherit version; };
    };

    overlays.default = final: prev: packages;
  });
}

