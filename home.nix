{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  niriConfPath = ./niri-conf.kdl;
  obsidianVault = rec {name = "Vault"; path = "Obsidian/${name}";};
in
{
  home.username = "litc";
  home.homeDirectory = "/home/litc";

  home.sessionVariables = {
    TERMINAL = "kitty";
    NIXOS_OZONE_WL = "1";
  };

  # Версия состояния Home Manager
  home.stateVersion = "26.05";

  # Программы и настройки пользователя
  programs.git = {
    enable = true;
    userName = "litc0x3B";
    userEmail = "ur.waifu.is.explosive.loli@gmail.com";
  };

  home.packages = with pkgs; [
    nautilus
    geany #graphical text editor
    keepassxc
    xdg-terminal-exec
    heroic
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


    (callPackage ./agy-patched.nix {})
  ];

  programs.home-manager.enable = true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  programs.nh = {
    enable = true;
    # Указываем путь к вашему репозиторию Flake
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

  programs.noctalia = {
    enable = true;
    checkConfig = true;
    settings = ''
      [include]
      files = ["${./noctalia-config.toml}"]

      [wallpaper.default]
      path = "${./wallpaper.png}"

      [theme.templates.user.obsidian_extra]
      input_path = "${config.home.homeDirectory}/.local/state/noctalia/community-templates/obsidian/obsidian.css"
      output_path = "${config.home.homeDirectory}/${obsidianVault.path}/.obsidian/snippets/noctalia.css"
    '';
  };

  # home-manager.users.litc.sops;

  xdg.configFile."niri/config.kdl".source =
    pkgs.runCommand "niri-config-checked"
      {
        nativeBuildInputs = [ pkgs.niri ];
      }
      ''
        ${pkgs.niri}/bin/niri validate --config ${niriConfPath}
        cat ${niriConfPath} > $out
      '';

  xdg.configFile."xdg-terminals.list".text = ''
    kitty.desktop
  '';


  programs.firefox = {
    enable = true;

    nativeMessagingHosts = [
      pkgs.pywalfox-native
    ];

    globalExtensions = with pkgs.nur.repos.rycee.firefox-addons; [
      ublock-origin
      pywalfox
      raindropio
      # (buildFirefoxXpiAddon {
      #   pname = "definer";
      #   version = "2.0.2";
      #   addonId = "definer@lumetrium.com";
      #   url = "https://addons.mozilla.org/firefox/downloads/file/5032364/lumetrium_definer-2.0.2.xpi";
      #   sha256 = "1d227b52d608471e145a94b5242fed5a827adaaab9412db1e8832b14db7715d6";
      #   meta = { };
      # })
      unofficial-saladict-popup-dictionary
    ];
  };

  gtk = {
    enable = true;

    theme = {
      name = "adw-gtk3"; # Точное имя темы
      package = pkgs.adw-gtk3; # Пакет с темой в nixpkgs
    };

    iconTheme = {
      name = "Flat-Remix-Blue-Dark";
      package = pkgs.flat-remix-icon-theme;
    };

    # iconTheme = 
    # {
    #   package = pkgs.papirus-icon-theme;
    #   name = "Papirus-Dark";
    # };
  };

  programs.kitty = {
    enable = true;

    font.name = "FiraCode Nerd Font Mono";

    # Основной конфиг kitty.conf:
    extraConfig = ''
      include themes/noctalia.conf
    '';

    shellIntegration.mode = null;

    settings = {
      confirm_os_window_close = 0;
      window_padding_width = 4;
      background_opacity = 0.9;
      shell_integration = "enabled";
      paste_actions = "quote-urls-at-prompt";
    };

    # Если вы хотите, чтобы noctalia стилизовала и утилиту kitten diff,
    # тогда diffConfig тоже можно оставить:
    # diffConfig.extraConfig = ''
    #   include themes/noctalia.conf
    # '';
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "gnzh";
    };
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      yazi = "y";
      nt = "$TERMINAL --detach --directory .";
    };

    initContent = lib.mkMerge [
      (lib.mkBefore "ZSH_DISABLE_COMPFIX=\"true\"")
      ''
        # 1. Сохраняем оригинальную функцию Oh My Zsh под именем _orig_virtualenv_prompt_info
        functions -c virtualenv_prompt_info _orig_virtualenv_prompt_info

        # 2. Переопределяем virtualenv_prompt_info
        virtualenv_prompt_info() {
          # Если мы внутри Distrobox, выводим имя контейнера
          if [[ -n "$CONTAINER_ID" ]]; then
            print -rn -- "%F{magenta}[distrobox: $CONTAINER_ID]%f "
          fi

          # Вызываем оригинальную функцию Oh My Zsh (для Python venv)
          _orig_virtualenv_prompt_info
        }

        # 3. Синхронизация текущей директории с Yazi при выходе из subshell
        if [[ -n "$YAZI_CWD_FILE" ]]; then
          zshexit() {
            pwd > "$YAZI_CWD_FILE"
          }
        fi
      ''
    ];

  };

  programs.yazi.enableZshIntegration = true;

  programs.yazi.enable = true;

  programs.yazi.keymap = {
    # input.prepend_keymap = [
    #   { run = "close"; on = [ "<C-q>" ]; }
    #   { run = "close --submit"; on = [ "<Enter>" ]; }
    #   { run = "escape"; on = [ "<Esc>" ]; }
    #   { run = "backspace"; on = [ "<Backspace>" ]; }
    # ];
    mgr.prepend_keymap = [
      {
        on = [ "!" ];
        run = ''shell 'target="$(mktemp)"; trap "rm -f \"$target\"" EXIT; YAZI_CWD_FILE="$target" "$SHELL"; [ -s "$target" ] && ya emit cd "$(cat "$target")"' --block'';
        desc = "Drop to shell and sync directory on exit";
      }
      {
        on = [ "<A-s>" ];
        run = ''shell --orphan "$TERMINAL"'';
        desc = "Open new terminal in current directory";
      }
      # { run = "quit"; on = [ "q" ]; }
      # { run = "close"; on = [ "<C-q>" ]; }
    ];
  };

  programs.yazi.settings = {
    opener = {
      # 1. Открыть файл в текстовом редакторе в новом окне Kitty
      term-edit = [
        {
          run = ''$TERMINAL -- $EDITOR %s'';
          orphan = true;
          desc = "Edit in new terminal window";
        }
      ];

      # 2. Запустить исполняемый скрипт/бинарник в новом терминале:
      term-run = [
        {
          run = ''$TERMINAL -- %s'';
          orphan = true;
          desc = "Run in new Kitty window";
        }
      ];
    };

    open = {
      prepend_rules = [
        # Текстовые файлы:
        {
          mime = "text/*";
          use = [
            "edit"
            "term-edit"
          ];
        }
        # Скрипты:
        {
          url = "*.sh";
          use = [
            "term-run"
            "term-edit"
            "edit"
          ];
        }
      ];
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "noctalia";
      vim_keys = true;
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      "text/x-csrc" = [ "geany.desktop" ];
    };
  };

  # programs.firefox.preferences = {
  #   "browser.tabs.tabmanager.enabled" = false;
  # }
  # ;

  programs.obsidian = {
    enable = true;
    vaults."${obsidianVault.name}" = {
      enable = true;
      target = obsidianVault.path;
    };
  };

  home.file."${obsidianVault.path}/.keep".text = "";



  # Периодическая двусторонняя синхронизация rclone bisync
  services.rclone-sync = {
    enable = true;
    autoResync = false;
    resyncOnFirstRun = true;
    intervalMinutes = 3; # n минут (max-lock автоматически будет установлен в (n - 1)m)
    createPath1 = true; # автоматически создавать Path1, если отсутствует (по умолчанию false для безопасности)
    createPath2 = true; # автоматически создавать Path2, если отсутствует (по умолчанию false)
    paths = [
      [ "/home/litc/Sync" "gd-vhivhi:save_files" ]
      # Или с явными именами и переопределением createPath:
      # {
      #   path1 = "/home/litc/Pictures";
      #   path2 = "remote:Pictures";
      #   createPath1 = true;
      #   createPath2 = true;
      # }
    ];
  };

}

