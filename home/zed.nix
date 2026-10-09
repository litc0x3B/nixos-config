{ lib, pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "nix"
      "kdl"
      "git-firefly"
      "toml"
      "tokyo-night"
      "yaml"
      "csharp"
      "lua"
    ];

    userSettings = {
      agent_servers = {
        antigravity-acp = {
          type = "registry";
        };
      };
      project_panel = {
        hide_gitignore = false;
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
