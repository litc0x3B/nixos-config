{
  lib,
  config,
  myConfig,
  self,
  ...
}:
let
  mkLinks = import ./mk-links.nix {
    inherit
      lib
      config
      myConfig
      self
      ;
    homePath = myConfig.homePath;
    basePath = myConfig.basePath;
  };
in
{
  xdg.configFile = mkLinks "config" [
    "zed/settings.json"
    "zed/keymap.json"
    "niri/config.kdl"
    "niri/pin-rules.json"
    "niri/window-rules.kdl"
    "kitty/kitty.conf"
    # "micro/settings.json"
    # "micro/bindings.json"
    # { "noctalia/exported.toml" = "noctalia/tokyo-night-new-new-lmao.toml"; }

    "nvim"
  ];

  xdg.dataFile = mkLinks "" {
    "noctalia/plugins/ruh-vpn" = "noctalia-plugins/ruh-vpn";
  };
}
