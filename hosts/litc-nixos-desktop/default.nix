{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  # Загрузчик UEFI (systemd-boot)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Прошивки для Wi-Fi, Bluetooth и Realtek оборудования
  hardware.enableRedistributableFirmware = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Видеокарта NVIDIA (GTX 1060 / Pascal)
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  hardware.nvidia = {
    # Режимы KMS для Wayland / Niri
    modesetting.enable = true;

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Для Pascal (GTX 1060) и старше открытые модули ядра не поддерживаются
    open = false;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Early KMS: загрузка драйвера NVIDIA в initrd для Plymouth
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  # Переменные окружения для Wayland / Niri
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };

  # Дополнительные настройки Home Manager для хоста litc-nixos-desktop
  home-manager.users.litc = import ./home;
}
