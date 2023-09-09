{
  description = "Virgutils, multiple utils used in Zhaith Izaliel's system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs }:
  let
    system  = "x86_64-linux";
  in
  with import nixpkgs { inherit system; };
  rec {
    devShells = {
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
          grimblast
          bluez
        ];
      };
      default = devShells.workspaceShell;
    };

    packages.${system} = {
    };

    overlays.default = [
      (final: prev: packages.${system})
    ];
  };
}

