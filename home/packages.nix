{ pkgs, ... }:
{
  home.packages = with pkgs; [
    keepassxc
    xdg-terminal-exec # what is that?
    heroic
    noctalia

    # dorion  #discord client
    vesktop
    lutris
    cine # mpv based video player
    telegram-desktop
    file-roller
    rclone
    obsidian

    #dependencies for youtube music noctalia plugin
    yt-dlp
    mpv
    jq
    curl
    netcat-openbsd

    #dependencies for ruh vpn noctalia plugin
    sing-box
    procps
    (python3.withPackages (
      ps: with ps; [
        pydantic
        aiofiles
        aiohttp
        aiohttp-socks
      ]
    ))

    # for noctalia qt6 theming template
    qt6Packages.qt6ct
    #btw template dosen't work

    #nix search plugin
    nix-search-tv
    fzf # also needed for zoxide and yazi (yazi probably has it as dependency?)

    # development and shit
    nodejs

    zoxide # smart cd, supports yazi integration

    lazygit
    zed-editor
    kitty
    micro
    chezmoi

    # rclone-ui
    ncdu

    (callPackage ./agy-patched.nix { })
    niri-window-pin
    rc-sync

    #nvim kickstart
    neovim
    git
    gcc
    unzip
    gnumake
    ripgrep
    fd
    tree-sitter
  ];
}
