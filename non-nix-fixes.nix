{ pkgs, ... }:

{
  # Включение генерации каталога шрифтов в /run/current-system/sw/share/X11/fonts
  fonts.fontDir.enable = true;

  # Поддержка FUSE bindfs для маунта с разыменованием симлинков
  system.fsPackages = [ pkgs.bindfs ];

  # Проброс системных шрифтов, иконок и тем в стандартные FHS-пути /usr/share
  fileSystems."/usr/share/fonts" = {
    device = "/run/current-system/sw/share/X11/fonts";
    fsType = "fuse.bindfs";
    options = [
      "ro"
      "x-gvfs-hide"
      "resolve-symlinks"
    ];
  };

  fileSystems."/usr/share/icons" = {
    device = "/run/current-system/sw/share/icons";
    fsType = "fuse.bindfs";
    options = [
      "ro"
      "x-gvfs-hide"
      "resolve-symlinks"
    ];
  };

  fileSystems."/usr/share/themes" = {
    device = "/run/current-system/sw/share/themes";
    fsType = "fuse.bindfs";
    options = [
      "ro"
      "x-gvfs-hide"
      "resolve-symlinks"
    ];
  };

  # Линковка директорий тем и иконок в /run/current-system/sw/share
  environment.pathsToLink = [
    "/share/icons"
    "/share/themes"
  ];

  # Системные пакеты оформления, чтобы они были доступны non-Nix приложениям через /usr/share
  # environment.systemPackages = with pkgs; [
  #   adw-gtk3
  #   tela-icon-theme
  #   bibata-cursors
  # ];
}
