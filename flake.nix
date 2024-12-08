{
  description = "Virgutils, multiple utils used in Zhaith Izaliel's system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fast-blur = {
      url = "github:bfraboni/FastGaussianBlur";
      flake = false;
    };
  };

  outputs = inputs @ {
    flake-parts,
    fast-blur,
    hyprland-contrib,
    ...
  }: let
    version = "1.18.1";
  in
    flake-parts.lib.mkFlake {inherit inputs;} ({...}: {
      imports = [
        flake-parts.flakeModules.easyOverlay
      ];

      systems = ["x86_64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: let
        fastblur = pkgs.callPackage ./dependencies/fastblur.nix {input = fast-blur;};
        grimblast = hyprland-contrib.packages.${system}.grimblast;
      in {
        overlayAttrs = config.packages;

        devShells = {
          # nix develop
          default = pkgs.mkShell {
            nativeBuildInputs =
              (with pkgs; [
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
                bluez
                gnugrep
                gnused
                coreutils
                wlr-randr
                power-profiles-daemon
                node2nix
                hyprsunset
              ])
              ++ [
                grimblast
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
            inherit version fastblur grimblast;
          };
          screenshot = pkgs.callPackage ./screenshot {
            inherit version grimblast;
          };
          dunstbar = pkgs.callPackage ./dunstbar {inherit version;};
          power-profilesbar = pkgs.callPackage ./power-profilesbar {inherit version;};
        };
      };
    });
}
