{ pkgs, inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ../../disko-config.nix
    ./hardware-configuration.nix
  ];

  # Загрузчик GRUB для VM
  boot.loader.grub.enable = true;

  # Гостевые службы VMware
  virtualisation.vmware.guest.enable = true;

  # Специфичные системные настройки для хоста litc-nixos-vm
  # Переопределение гритера: для VM отключаем Noctalia Greeter и используем текстовый tuigreet
  services.displayManager.noctalia-greeter.enable = false;
  services.greetd.settings.default_session.command =
    "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --asterisks --cmd niri-session";

  systemd.tmpfiles.rules = [
    "d '/var/cache/tuigreet' 0755 greeter greeter - -"
  ];

  # Дополнительные настройки Home Manager для хоста litc-nixos-vm
  home-manager.users.litc = import ./home.nix;
}
