{ lib, ... }:
{
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "gnzh";
      plugins = [ "virtualenv" ];
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

          # Если мы внутри subshell Yazi, выводим индикатор
          if [[ -n "$YAZI_LEVEL" ]]; then
            if [[ "$YAZI_LEVEL" -gt 1 ]]; then
              print -rn -- "%F{cyan}[yazi: $YAZI_LEVEL]%f "
            else
              print -rn -- "%F{cyan}[yazi]%f "
            fi
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

        eval "$(zoxide init zsh)"

        export EDITOR="micro";
        export SUDO_EDITOR="micro";
        export MICRO_TRUECOLOR=1;
      ''
    ];

  };
}
