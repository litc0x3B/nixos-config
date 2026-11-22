{ pkgs, inputs, ... }:
let
  pkgs-agy = import inputs.nixpkgs-agy {
    config = { inherit (pkgs.config) allowUnfree; };
    system = pkgs.stdenv.hostPlatform.system;
  };
  pkgs-unfree = import inputs.nixpkgs-unfree {
    config = { inherit (pkgs.config) allowUnfree; };
    system = pkgs.stdenv.hostPlatform.system;
  };
in
{
  home.packages = with pkgs; [
    xdg-terminal-exec # what is that?
    heroic
    # installed globally
    # noctalia

    # dorion  #discord client
    vesktop
    (lutris.override {
      lutris-unwrapped = lutris-unwrapped.overridePythonAttrs (old: {
        dependencies = (old.dependencies or [ ]) ++ [ python3Packages.pefile ];
      });
    })
    # cine # mpv based video player
    telegram-desktop
    file-roller
    rclone
    obsidian

    #dependencies for youtube music noctalia plugin
    yt-dlp
    # mpv #installed with hm
    jq
    curl
    netcat-openbsd

    # search noctalia plugin
    xdg-utils

    #dependencies for ruh vpn noctalia plugin
    sing-box
    procps
    (python3.withPackages (
      ps: with ps; [
        pydantic
        aiofiles
        aiohttp
        aiohttp-socks


        # wallpaper depth deps
        numpy
        onnxruntime
        pillow
      ]
    ))

    #nix search plugin
    nix-search-tv
    fzf # also needed for zoxide and yazi (yazi probably has it as dependency?)

    # development and shit
    nodejs

    zoxide # smart cd, supports yazi integration

    lazygit
    kitty
    # micro
    chezmoi

    # rclone-ui
    ncdu
    miktex

    (callPackage ./agy-patched.nix {
      pkgs = pkgs-agy;
      agypatch = inputs.agypatch;
    })

    (callPackage ./agy-hub-patched.nix {
      pkgs = pkgs-agy;
      agypatch = inputs.agypatch;
    })
    # pkgs-agy.antigravity-hub
    # niri-window-pin
    rc-sync
    pkgs-unfree.ouch-rar

    #nvim kickstart
    neovim
    git
    gcc
    unzip
    gnumake
    ripgrep
    fd
    tree-sitter

    nixos-anywhere
    seahorse

    hyprpicker
    onlyoffice-desktopeditors
    # pixelorama
    pkgs-unfree.aseprite
    dotnet-sdk_10
    devenv
    uv

    pavucontrol
    tailspin
    nix-alien

    godotPackages_4_7.godot-mono
    gamescope
    mission-center
    qbittorrent
    super-productivity
    cowsay

    file
    handlr-regex
    inputs.app-manager.packages.x86_64-linux.default
    # ristretto
    # gapless
    # amberol
    # semito
  ];
}
