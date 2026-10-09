{
  config,
  lib,
  osConfig ? null,
  ...
}:
let
  cursorName = config.home.pointerCursor.name;
  cursorSize = builtins.toString config.home.pointerCursor.size;
  gtkTheme = config.gtk.theme.name;
  qtStyle =
    if osConfig != null && osConfig.programs ? qtengine then
      osConfig.programs.qtengine.config.theme.style
    else
      "breeze";
in
{
  services.flatpak = {
    enable = true;

    packages = [
      "com.vysp3r.ProtonPlus"
      "com.github.tchx84.Flatseale"
      # "com.usebottles.bottles"
      # "io.github.giantpinkrobots.varia"
      #
    ];
    # ++ lib.optionals (gtkTheme == "adw-gtk3") [
    #   "org.gtk.Gtk3theme.adw-gtk3"
    #   "org.gtk.Gtk3theme.adw-gtk3-dark"
    # ];

    overrides = {
      writeMode = "replace";
      settings = {

        "com.usebottles.bottles" = {
          Context.filesystems = [
            "~/Games"
            "~/WinePrefixes"
            "xdg-data/Steam"
            "xdg-data/applications"
            "/run/media:ro"
          ];
        };

        global = {
          Context.filesystems = [
            # Доступ к хранилищу Nix для чтения файлов по симлинкам
            "/nix/store:ro"

            # Профиль пользователя Home Manager
            "~/.nix-profile/share:ro"

            # Пользовательские каталоги тем, иконок, шрифтов и цветовых схем
            "xdg-data/themes:ro"
            "xdg-data/icons:ro"
            "xdg-data/fonts:ro"
            "xdg-data/color-schemes:ro"
            "~/.icons:ro"
            "~/.themes:ro"

            # Системные каталоги (fallback)
            "/run/current-system/sw/share/themes:ro"
            "/run/current-system/sw/share/icons:ro"

            # Пользовательские конфиги оформления (Noctalia генерирует стили сюда)
            "xdg-config/gtk-3.0:ro"
            "xdg-config/gtk-4.0:ro"
            "xdg-config/fontconfig:ro"
            "xdg-config/kdeglobals:ro"
            "xdg-config/qt6ct:ro"
            "xdg-config/qt5ct:ro"
          ];

          Environment = {
            XCURSOR_THEME = cursorName;
            XCURSOR_SIZE = cursorSize;
            XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons:~/.icons";
            QT_QPA_PLATFORMTHEME = "gtk3";
            QT_STYLE_OVERRIDE = qtStyle;
          };
        };
      };
    };
  };
}
