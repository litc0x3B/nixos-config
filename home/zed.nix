{ lib, pkgs, ... }:
let
  nixdWrapper = pkgs.writeShellScriptBin "nixd-devenv-wrapper" ''
    if command -v devenv >/dev/null 2>&1; then
      DEVENV_BIN="devenv"
    else
      DEVENV_BIN="${pkgs.devenv}/bin/devenv"
    fi

    if command -v nixd >/dev/null 2>&1; then
      NIXD_BIN="nixd"
    else
      NIXD_BIN="${pkgs.nixd}/bin/nixd"
    fi

    dir="$PWD"
    while [ "$dir" != "/" ]; do
      if [ -f "$dir/devenv.nix" ]; then
        cd "$dir"
        exec "$DEVENV_BIN" lsp "$@"
      fi
      dir="$(dirname "$dir")"
    done

    exec "$NIXD_BIN" "$@"
  '';
in
{
  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor.fhsWithPackages (
      pkgs: with pkgs; [
        # dotnetCorePackages.dotnet_10.sdk
        # dotnetCorePackages.dotnet_10.aspnetcore
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
            path = "${nixdWrapper}/bin/nixd-devenv-wrapper";
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

    userKeymaps = [
      {
        context = "Workspace";
        bindings = { };
      }
      {
        context = "Editor && vim_mode == insert";
        bindings = { };
      }
      {
        context = "Terminal";
        bindings = {
          "ctrl-shift-v" = "terminal::Paste";
        };
      }
    ];
  };
}
