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
    version  = "1.0.0";
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
          gnugrep
          coreutils
          wlr-randr
        ];
      };
      default = devShells.${system}.workspaceShell;
    };

    packages.${system} = {
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
    };

    overlays.default = [
      (final: prev: packages.${system})
    ];
  };
}

