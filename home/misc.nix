{
  pkgs,
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
    package = pkgs.vscode.fhs;
  };

  programs.nh = {
    enable = true;
    flake = "/home/litc/Nixos";

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

  programs.firefox = {
    enable = true;

    nativeMessagingHosts = [
      pkgs.pywalfox-native
    ];

    profiles = {
      "default" = {
        id = 0;
        path = "g2pc3f7n.default";
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

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
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

  # Периодическая двусторонняя синхронизация rclone bisync
  # services.rclone-sync = {
  #   enable = true;
  #   autoResync = false;
  #   resyncOnFirstRun = true;
  #   intervalMinutes = 3; # n минут (max-lock автоматически будет установлен в (n - 1)m)
  #   createPath1 = true; # автоматически создавать Path1, если отсутствует (по умолчанию false для безопасности)
  #   createPath2 = true; # автоматически создавать Path2, если отсутствует (по умолчанию false)
  #   paths = [
  #     [
  #       "/home/litc/Sync"
  #       "gd-vhivhi:save_files"
  #     ]
  #     # Или с явными именами и переопределением createPath:
  #     # {
  #     #   path1 = "/home/litc/Pictures";
  #     #   path2 = "remote:Pictures";
  #     #   createPath1 = true;
  #     #   createPath2 = true;
  #   ];
  # };
  #

  services.rc-sync = {
    enable = true;
    settings = {
      global_flags = "--resilient --recover --max-lock %tm";
      sync_freq_minutes = 3;
      mappings = {
        sync = {
          path1 = "~/Sync";
          path2 = "gd-vhivhi:save_files";
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
