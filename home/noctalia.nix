{
  osConfig,
  myConfig,
  config,
  ...
}:
{
  xdg.configFile."noctalia/config.toml".text = ''
    [include]
    autoload = false
    files = ["${myConfig.fullHomePath}/config/noctalia/tokyo-night-new-new-lmao.toml"]

    [wallpaper.default]
    path = "${./wallpaper.png}"

    [plugin_settings."mindnbytes/nix-status"]
    flake_dir = "${myConfig.basePath}"
    nixos_configuration = "${osConfig.networking.hostName}"
  '';
}
