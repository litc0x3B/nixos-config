{
  lib,
  config,
  homePath,
  basePath,
  self,
  ...
}:
let
  mkSymlink = path: config.lib.file.mkOutOfStoreSymlink "${path}";
  mkLinks =
    prefix: entries:
    let
      pre = if prefix != "" then "${prefix}/" else "";
      processPair =
        target: rawSrc:
        let
          src = if rawSrc != null && rawSrc != "" then rawSrc else target;
          pathRelToBase = "${homePath}/${pre}${src}";
          pathStore = self + "/${pathRelToBase}";
          realFullPath = "${basePath}/${pathRelToBase}";

          # Мы надеемся на то что basePath указан правильно и что в self будет вся та же структура файлов
          _ =
            if !builtins.pathExists pathStore then
              throw "mkLinks: исходный путь '${pathStore}' для '${target}' не найден в репозитории (проверьте путь или выполните 'git add')"
            else
              null;
        in
        builtins.seq _ {
          source = mkSymlink (builtins.trace "evaluated path ${realFullPath}" realFullPath);
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
mkLinks
