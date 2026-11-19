{ lib, pkgs, ... }:
let
#   nixdWrapper = pkgs.writeShellScriptBin "nixd-devenv-wrapper" ''
#     if command -v devenv >/dev/null 2>&1; then
#       DEVENV_BIN="devenv"
#     else
#       DEVENV_BIN="${pkgs.devenv}/bin/devenv"
#     fi
#
#     if command -v nixd >/dev/null 2>&1; then
#       NIXD_BIN="nixd"
#     else
#       NIXD_BIN="${pkgs.nixd}/bin/nixd"
#     fi
#
#     dir="$PWD"
#     while [ "$dir" != "/" ]; do
#       if [ -f "$dir/devenv.nix" ]; then
#         cd "$dir"
#         exec "$DEVENV_BIN" lsp "$@"
#       fi
#       dir="$(dirname "$dir")"
#     done
#
#     exec "$NIXD_BIN" "$@"
#   '';
in
{
  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor.fhsWithPackages (
      pkgs: with pkgs; [
        dotnet-sdk_10
      ]
    );

    extensions = [
      "nix"
      "kdl"
      "git-firefly"
      "toml"
      "tokyo-night"
      "yaml"
      "csharp"
      # "lua"
    ];

    userSettings = {
      languages = {
        Nix = {
          language_servers = [
            "nixd"
            "!nil"
          ];
        };
      };
      lsp = {
        nixd = {
          binary = {
            # path = "${nixdWrapper}/bin/nixd-devenv-wrapper";
            path = "${pkgs.nixd}/bin/nixd";
          };
        };
      };
      agent_servers = {
        antigravity-acp = {
          type = "registry";
        };
      };
      project_panel = {
        hide_gitignore = false;
        dock = "left";
      };
      outline_panel = {
        dock = "left";
      };
      git_panel = {
        dock = "left";
      };
      collaboration_panel = {
        dock = "left";
      };
      agent_panel = {
        dock = "left";
      };
      cli_default_open_behavior = "existing_window";
      icon_theme = {
        mode = "light";
        light = "Zed (Default)";
        dark = "Zed (Default)";
      };
      ui_font_size = lib.mkDefault 16;
      buffer_font_size = lib.mkDefault 15;
      theme = {
        mode = "system";
        light = "Noctalia Light";
        dark = "Noctalia Dark";
      };
    };



    userTasks = [
      {
        label = "Open External Terminal";
        command = "sh";
        args = [
          "-c"
          ''
            DIR="''${ZED_WORKTREE_ROOT:-''${ZED_DIRNAME:-$PWD}}"
            if command -v xdg-terminal-exec >/dev/null 2>&1; then
              exec setsid -f xdg-terminal-exec --dir="$DIR"
            elif [ -n "$TERMINAL" ]; then
              exec setsid -f "$TERMINAL" --working-directory "$DIR"
            else
              exec setsid -f kitty --working-directory "$DIR"
            fi
          ''
        ];
        reveal = "never";
        hide = "always";
        allow_concurrent_runs = true;
      }
    ];

    # {
    #   "context": "!Terminal",
    #   "unbind": {
    #     "ctrl-shift-c": "collab_panel::ToggleFocus"
    #   }
    # }

    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          "ctrl-shift-c" = [
            "task::Spawn"
            {
              task_name = "Open External Terminal";
            }
          ];
        };
      }
      {
        context = "Editor && vim_mode == insert";
        bindings = { };
      }
      {
        context = "Terminal";
        bindings = {
          "ctrl-shift-c" = "terminal::Copy";
          "ctrl-shift-v" = "terminal::Paste";
        };
      }
      {
        context = "!Terminal";
        unbind = {
          "ctrl-shift-c" = "collab_panel::ToggleFocus";
        };
      }
    ];
  };
}
