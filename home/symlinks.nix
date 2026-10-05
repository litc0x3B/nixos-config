{
  lib,
  config,
  ...
}:
let
  homeCfgDir = "${config.home.homeDirectory}/Nixos/home";
  mkSymlink = path: config.lib.file.mkOutOfStoreSymlink "${homeCfgDir}/${path}";

  # Вспомогательная функция для маппинга симлинков с проверкой существования исходного файла
  mkLinks =
    prefix: entries:
    let
      pre = if prefix != "" then "${prefix}/" else "";
      processPair =
        target: rawSrc:
        let
          src = if rawSrc != null && rawSrc != "" then rawSrc else target;
          fullSrc = "${pre}${src}";
          localPath = ./. + "/${fullSrc}";
          _ =
            if !builtins.pathExists localPath then
              throw "mkLinks: исходный путь '${fullSrc}' для '${target}' не найден в репозитории (проверьте путь или выполните 'git add')"
            else
              null;
        in
        builtins.seq _ {
          source = mkSymlink fullSrc;
        };
      toPair =
        entry:
        if builtins.isString entry then
          { "${entry}" = processPair entry entry; }
        else if builtins.isAttrs entry then
          lib.mapAttrs processPair entry
        else
          throw "mkLinks: elements must be strings or attribute sets";
    in
    if builtins.isList entries then
      lib.mergeAttrsList (map toPair entries)
    else if builtins.isAttrs entries then
      toPair entries
    else
      throw "mkLinks: expected a list or attribute set";
in
{
  xdg.configFile = mkLinks "config" [
    "zed/settings.json"
    "zed/keymap.json"
    "niri"
    "kitty/kitty.conf"
    # "micro/settings.json"
    # "micro/bindings.json"
    { "noctalia/exported.toml" = "noctalia/tokyo-night-new-new-lmao.toml"; }
  ];

  xdg.dataFile = mkLinks "" {
    "noctalia/plugins/ruh-vpn" = "noctalia-plugins/ruh-vpn";
  };
}
