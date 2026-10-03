{
  config,
  ...
}:
let
  dotfilesSource = "${config.home.homeDirectory}/Nixos/home/chezmoi-source";
in
{

  xdg.configFile."chezmoi/chezmoi.toml".text = ''
    sourceDir = "${dotfilesSource}"
  '';
}
