{ ... }:
{
  xdg.configFile."noctalia/config.toml".text = ''
    [include]
    autoload = false
    files = ["exported.toml"]
    [wallpaper.default]
    path = "${./wallpaper.png}"
  '';
}
