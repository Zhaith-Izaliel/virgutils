{
  description = "Virgutils, multiple utils used in Zhaith Izaliel's system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    hyprwm-contrib.url = "github:hyprwm/contrib";
  };

  outputs = { nixpkgs, hyprwm-contrib, ...}:
  let
    system  = "x86_64-linux";
  in
  with import nixpkgs { inherit system; };
  rec {
    devShells.${system} = {
      workspaceShell = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          bashInteractive
          brightnessctl
          dunst
          looking-glass-client
          virt-manager
          wireplumber
          gawk
          bc
          gnused
          sudo
          wlogout
          imagemagick
          hyprwm-contrib.packages.${system}.grimblast
          bluez
          coreutils
          wlr-randr
        ];
      };
      default = devShells.${system}.workspaceShell;
    };

    packages.${system} = {
    };

    overlays.default = [
      (final: prev: packages.${system})
    ];
  };
}

