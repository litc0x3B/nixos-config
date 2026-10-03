{ lib, pkgs, ... }:
{
  programs.yazi.enableZshIntegration = true;

  programs.yazi.enable = true;

  programs.yazi.keymap = {
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
          run = "$TERMINAL -- $EDITOR %s";
          orphan = true;
          desc = "Edit in new terminal window";
        }
      ];

      # 2. Запустить исполняемый скрипт/бинарник в новом терминале:
      term-run = [
        {
          run = "$TERMINAL -- %s";
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
}
