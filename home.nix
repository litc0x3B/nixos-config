{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  niriConfPath = ./niri-conf.kdl;
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
    '';
  };

  # home-manager.users.litc.sops;

  xdg.configFile."niri/config.kdl".source =
    pkgs.runCommand "niri-config-checked"
      {
        nativeBuildInputs = [ pkgs.niri ];
      }
      ''
        niri validate --config ${niriConfPath}

        cat ${niriConfPath} > $out
        printf "\n\ninclude \"noctalia.kdl\"\n" >> $out
      '';

  programs.firefox.globalExtensions = with pkgs.nur.repos.rycee.firefox-addons; [
    privacy-badger
    {
      package = ublock-origin;
      settings = {
        private_browsing = true;
      };
    }
  ];

  gtk = {
    enable = true;

    theme = {
      name = "adw-gtk3"; # Точное имя темы
      package = pkgs.adw-gtk3; # Пакет с темой в nixpkgs
    };

    iconTheme = {
      name = "Zafiro-icons-Dark";
      package = pkgs.zafiro-icons;
    };
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
      window_padding_width = 3;
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
      ''
    ];

  };

  programs.yazi.enableZshIntegration = true;

  programs.yazi.keymap = {
    # input.prepend_keymap = [
    #   { run = "close"; on = [ "<C-q>" ]; }
    #   { run = "close --submit"; on = [ "<Enter>" ]; }
    #   { run = "escape"; on = [ "<Esc>" ]; }
    #   { run = "backspace"; on = [ "<Backspace>" ]; }
    # ];
    mgr.prepend_keymap = [
      {
        run = "shell \"$SHELL\" --block";
        on = [ "<alt> + s" ];
      }
      # { run = "quit"; on = [ "q" ]; }
      # { run = "close"; on = [ "<C-q>" ]; }
    ];
  };

  programs.yazi.settings = ''
    [opener]
    # 1. Открыть файл в текстовом редакторе (например, Neovim/Nano) в новом окне Kitty
    term-edit = [
        { run = 'kitty -- nvim "$@"', orphan = true, desc = "Edit in new Kitty window" }
    ]

    # 2. Если нужно просто запустить исполняемый скрипт/бинарник в новом терминале:
    term-run = [
        { run = 'kitty -- "$@"', orphan = true, desc = "Run in new Kitty window" }
    ]

    [open]
    rules = [
        # Добавляем наш opener в список доступных для текстовых файлов:
        { mime = "text/*", use = [ "edit", "term-edit" ] },
        # Для скриптов:
        { name = "*.sh",   use = [ "term-run", "term-edit", "edit" ] },
    ]
  '';

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
}
