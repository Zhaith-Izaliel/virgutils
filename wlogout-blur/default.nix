{
  pkgs,
  version,
  fastblur,
}:
pkgs.callPackage ../builder.nix {
  pname = "wlogout-blur";

  inherit version;

  src = ./.;

  buildInputs = with pkgs; [
    bash
  ];

  paths =
    (with pkgs; [
      imagemagick
      wlogout
      grimblast
      libnotify
    ])
    ++ [
      fastblur
    ];
}
