{ inputs, ... }:
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
  # (переопределения параметров из общей конфигурации)

  # Дополнительные настройки Home Manager для хоста litc-nixos-vm
  home-manager.users.litc = import ./home.nix;
}
