{ pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../disko-config.nix
  ];

  # Загрузчик для ноутбука (UEFI systemd-boot)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Управление питанием и батареей
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true; # Защита от перегрева Intel

  # Поведение при закрытии крышки
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
  };

  # Видеоядро Intel HD Graphics и аппаратное декодирование VA-API
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # Для Intel Core 5-го поколения и новее
      intel-vaapi-driver # Для старых поколений (до 4-го включительно)
      libva-utils # Утилита vainfo для проверки работы
    ];
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  # services.blueman.enable = true;

  # Поддержка тачпада
  services.libinput.enable = true;

  # Пакеты, специфичные для ноутбука
  environment.systemPackages = with pkgs; [
    brightnessctl # Управление яркостью экрана
    powertop # Мониторинг энергопотребления
  ];

  # Дополнительные настройки Home Manager для хоста litc-nixos-laptop
  home-manager.users.litc = import ./home;

  programs.qtengine = {
    enable = true;
    config = {
      theme = {
        font = {
          # family = "Sans Serif";
          size = 10;
          # weight = -1;
        };
        fontFixed = {
          # family = "FiraCode Nerd Font";
          size = 10;
          # weight = -1;
        };
      };
    };
  };
}
