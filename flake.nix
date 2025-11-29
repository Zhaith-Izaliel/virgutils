{
  description = "Virgutils, multiple utils used in Zhaith Izaliel's system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    fast-blur = {
      url = "github:bfraboni/FastGaussianBlur";
      flake = false;
    };
  };

  outputs = inputs @ {
    flake-parts,
    fast-blur,
    ...
  }: let
    version = "1.19.0";
  in
    flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      imports = [
        flake-parts.flakeModules.easyOverlay
      ];

      systems = ["x86_64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {
        config,
        pkgs,
        ...
      }: let
        fastblur = pkgs.callPackage ./dependencies/fastblur.nix {input = fast-blur;};
      in {
        overlayAttrs = config.packages;

        devShells = {
          # nix develop
          default = pkgs.mkShell {
            nativeBuildInputs =
              (with pkgs; [
                brightnessctl
                dunst
                libnotify
                wireplumber
                gawk
                bc
                gnused
                wlogout
                bluez
                gnugrep
                coreutils
                power-profiles-daemon
                node2nix
                niri
                wl-clipboard
              ])
              ++ [
                fastblur
              ];
          };
        };

        packages = {
          dim-on-lock = pkgs.callPackage ./dim-on-lock {inherit version;};
          hyprland-nightlights = pkgs.callPackage ./hyprland-nightlights {inherit version;};
          nix-npm-install = pkgs.callPackage ./nix-npm-install {inherit version;};
          power-management = pkgs.callPackage ./power-management {inherit version;};
          start-vm = pkgs.callPackage ./start-vm {inherit version;};
          toggle-bluetooth = pkgs.callPackage ./toggle-bluetooth {inherit version;};
          volume-brightness = pkgs.callPackage ./volume-brightness {inherit version;};
          wlogout-blur = pkgs.callPackage ./wlogout-blur {
            inherit version fastblur;
          };
          dunstbar = pkgs.callPackage ./dunstbar {inherit version;};
          power-profilesbar = pkgs.callPackage ./power-profilesbar {inherit version;};
        };
      };
    });
}
