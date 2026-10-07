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
  # home.sessionVariables = {
  #   GDK_DPI_SCALE = 0.85;
  # };
  xdg.configFile = mkLinks "" [
    { "niri/host-overrides.kdl" = "niri.kdl"; }
    { "kitty/host-overrides.conf" = "kitty.conf"; }
  ];

  # services.wlsunset =
  # {
  #   enable = true;
  #   gamma = 0.9;
  #   sunset = null;
  #   sunrise = null;
  #   temperature =
  # }
}
