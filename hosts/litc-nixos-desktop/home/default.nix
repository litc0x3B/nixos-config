{
  lib,
  config,
  myConfig,
  self,
  pkgs,
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
  xdg.configFile = mkLinks "" [
    { "niri/host-overrides.kdl" = "niri.kdl"; }
  ];

  services.rc-sync.settings.mappings = {
    gd-loli-full = {
      path1 = "/mnt/storage/GoogleDriveLoli";
      path2 = "gd-loli:/";
    };
    sync.enabled = false;
    wallpaper.enabled = false;
  };

  home.file."Pictures/Drive Pictures".source = config.lib.file.mkOutOfStoreSymlink "/mnt/storage/GoogleDriveLoli/pictures";
  home.file."Pictures/Wallpapers".source = config.lib.file.mkOutOfStoreSymlink "/mnt/storage/GoogleDriveLoli/linux-sync/wallpapers";
  home.file."Sync".source = config.lib.file.mkOutOfStoreSymlink "/mnt/storage/GoogleDriveLoli/save_files";

  home.packages = with pkgs; [
    # w engine
    linux-wallpaperengine
    ffmpeg
  ];
}
