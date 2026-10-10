{
  pkgs,
  lib,
  myConfig,
  config,
  self,
  ...
}:
let
  mkLinks = import ../../../home/mk-links.nix {
    inherit
      lib
      config
      myConfig
      self
      ;
    homePath = myConfig.hostHomePath;
    basePath = myConfig.basePath;
  };
in
{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      text-scaling-factor = 0.85; # например, 0.9 или 1.25
    };
  };

  gtk = {
    iconTheme = {
      package = lib.mkForce (pkgs.tela-icon-theme);
      name = lib.mkForce "Tela-yellow-dark";
    };
  };

  xdg.configFile = mkLinks "" [
    { "niri/host-overrides.kdl" = "niri.kdl"; }
    { "kitty/host-overrides.conf" = "kitty.conf"; }
  ];

  xdg.stateFile = mkLinks "" [
    { "noctalia/settings.toml" = "noctalia.toml"; }
  ];

  programs.zed-editor.userSettings = {
    ui_font_size = 14;
    buffer_font_size = 13;
    project_panel.indent_size = 12;
    project_panel.default_width = 120;
  };
}
