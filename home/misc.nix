{
  pkgs,
  config,
  lib,
  ...
}:
let
  obsidianVault = rec {
    name = "Vault";
    path = "Obsidian/${name}";
  };
in
{
  home.username = "litc";
  home.homeDirectory = "/home/litc";

  # Версия состояния Home Manager
  home.stateVersion = "26.05";

  # Программы и настройки пользователя
  programs.git = {
    enable = true;
    userName = "litc0x3B";
    userEmail = "ur.waifu.is.explosive.loli@gmail.com";
  };

  programs.home-manager.enable = true;
  programs.nix-index.enable = true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhsWithPackages (ps: with ps; [ nodejs ]);
  };

  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  xdg.configFile."xdg-terminals.list".text = ''
    kitty.desktop
  '';

  xdg.configFile."kdeglobals".text = ''
    [General]
    ColorScheme=noctalia

    [Icons]
    Theme=${config.gtk.iconTheme.name}
  '';

  xdg.dataFile."icons/${config.gtk.iconTheme.name}".source =
    "${config.gtk.iconTheme.package}/share/icons/${config.gtk.iconTheme.name}";

  programs.firefox = {
    enable = true;

    nativeMessagingHosts = [
      pkgs.pywalfox-native
    ];

    profiles = {
      "default" = {
        id = 0;
        path = "g2pc3f7n.default";
        settings = {
          # "browser.startup.homepage" = "https://nixos.org";
          # "browser.search.region" = "GB";
          # "browser.search.isUS" = false;
          # "distribution.searchplugins.defaultLocale" = "en-GB";
          # "general.useragent.locale" = "en-GB";
          # "browser.bookmarks.showMobileBookmarks" = true;
          # "browser.newtabpage.pinned" = [{
          #   title = "Gemini";
          #   url = "https://gemini.google.com";
          # }];
          "browser.sessionstore.max_resumed_crashes" = 0;
          "browser.newtabpage.activity-stream.showSearch" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.ctrlTab.sortByRecentlyUsed" = true;
        };
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          pywalfox
          raindropio
          unofficial-saladict-popup-dictionary
        ];
      };
    };
  };

  gtk = {
    enable = true;

    theme = {
      name = "adw-gtk3"; # Точное имя темы
      package = pkgs.adw-gtk3; # Пакет с темой в nixpkgs
    };

    iconTheme = {
      package = pkgs.tela-icon-theme;
      name = "Tela-blue-dark";
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "noctalia";
      vim_keys = true;
    };
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      "text/plain" = [ "dev.zed.Zed.desktop" ];
      "text/markdown" = [ "dev.zed.Zed.desktop" ];
      "text/x-csrc" = [ "dev.zed.Zed.desktop" ];
    };
  };

  # home.packages =
  #   let
  #     handlr = pkgs.handlr-regex;
  #   in
  #   [
  #     (pkgs.writeShellScriptBin "xdg-open" ''
  #       exec ${lib.getExe handlr} open "$@"
  #     '')
  #   ];

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gnome" ];
      };
      # niri = {
      #   default = [
      #     "gnome"
      #     "gtk"
      #   ];
      # };
    };
  };

  programs.obsidian = {
    enable = true;
    vaults."${obsidianVault.name}" = {
      enable = true;
      target = obsidianVault.path;
    };
  };

  home.file."${obsidianVault.path}/.keep".text = "";

  services.rc-sync = {
    enable = true;
    settings = {
      global_flags = "--resilient --recover --max-lock %tm";
      sync_freq_minutes = 4;
      mappings = {
        sync = {
          path1 = "~/Sync";
          path2 = "gd-vhivhi:save_files";
        };
        wallpaper = {
          path1 = "~/Pictures/Wallpapers";
          path2 = "gd-loli:linux-sync/wallpapers";
        };
      };
    };
  };

  # Автомонтирование внешних дисков для Wayland-окружения
  services.udiskie = {
    enable = true;
    notify = true;
    tray = "auto";
  };

}
